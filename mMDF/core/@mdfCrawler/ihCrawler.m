function res = ihCrawler(obj,cuuid,recursive,puuid)
    % function res = obj.ihCrawler(cobj,recursive,puuid)
    %
    % internal mdfCrawler recursive crawler
    %
    % Input
    %  cobj = (mdfObj) current object analyzed
    %  recursive = (logical) if true, continue to lower level
    %              if false, stop at this object
    %
    % Output
    %  res = return status
    %
    
    % output status
    res = 0;

    if nargin < 3
        recursive = false;
    end %if
    if nargin < 4
        puuid = '';
    end %if
    
    % convert current uuid to matlab accaptable form
    muuid = ['uuid_' regexprep(cuuid,'-','_')];
    
    % check if we already visited this object or not
    if recursive && isfield(obj.objList,muuid)
       % we already visited this object
       % ingore it and return
       return;
    end %if
        
    % check if object is in memory or not
	om = mdfManage.getInstance();
    inmem = om.exist(cuuid);
    
    % load object
    cobj = mdf.load(cuuid);

	% debug only
    disp(['mdfCrawler:ihCrawler - uuid : ' cuuid ', type : ' cobj.type]); 

    % initialize item struct
    item = struct();
    % initialize hierarchical item struct
    hitem = struct();
    
    % populate output with current object
    item.name = [cobj.type ' ' cuuid];
    item.info = struct( ...
        'type', cobj.type, ...
        'uuid', cobj.uuid, ...
        'vuuid', cobj.vuuid, ...
        'created', cobj.created, ...
        'modified', cobj.modified);
    % data
    % initialize data entry
    item.data = struct();
    % get list of data fields
    fl = cobj.mdf_def.mdf_data.mdf_fields;
    % loop on each field and insert references
    for i = 1:length(fl)
        % get data field name
        name = fl{i};
        % insert size type and memory footprint
        item.data.(name) = ...
            sprintf('[%dx%d %s %d]', ...
                cobj.mdf_def.mdf_data.(name).mdf_size(1), ...
                cobj.mdf_def.mdf_data.(name).mdf_size(2), ...
                cobj.mdf_def.mdf_data.(name).mdf_class, ...
                cobj.mdf_def.mdf_data.(name).mdf_mem);
    end %for
    % MN : 2016/09/02
    % changed from preinting the all structure
    %item.metadata = cobj.metadata;
    % to printing just the first level
    item.metadata = struct();
    fl = fields(cobj.metadata);
    for i = 1:length(fl)
        % get name
        name = fl{i};
        % address mutliple type of metadata
        if isnumeric(cobj.metadata.(name)) || ...
                islogical(cobj.metadata.(name))
            % if array is longer than 5 elements, show only the first 5 and
            % append ...
            if length(cobj.metadata.(name)) <= 5 && isvector(cobj.metadata.(name))
                % print value
                item.metadata.(name) = cobj.metadata.(name);
            elseif max(size(cobj.metadata.(name))) == 0
                % address empty properties
                item.metadata.(name) = sprintf('[0x0 %s]',class(cobj.metadata.(name)));
            else
                % takes care of matrices, row and column vectors
                if ~isvector(cobj.metadata.(name))
                    temp = cobj.metadata.(name);
                    temp = temp( ...
                            1, ...
                            1:min(5,size(cobj.metadata.(name),2)));
                else
                    temp = cobj.metadata.(name)(1:min(5,length(cobj.metadata.(name))));
                end %if
                item.metadata.(name) = [ ...
                    regexprep( ...
                        mat2str( temp ), ...
                        ']', ...
                        ' ... ]'), ...
                    sprintf('[%dx%d %s]', ...
                        size(cobj.metadata.(name),1), ...
                        size(cobj.metadata.(name),2), ...
                        class(cobj.metadata.(name)))];
            end %if
        elseif ischar(cobj.metadata.(name))
        	% print string
            % shorten strings longer than 80 characters
            if length(cobj.metadata.(name)) > 80
                item.metadata.(name) = ...
                    [ cobj.metadata.(name)(1:79) '...'];
            else
                item.metadata.(name) = cobj.metadata.(name);
            end %if
        else
            % print type and size
            item.metadata.(name) = ...
                sprintf('[%dx%d %s]', ...
                        size(cobj.metadata.(name),1), ...
                        size(cobj.metadata.(name),2), ...
                        class(cobj.metadata.(name)));
        end %if
    end %for
    % get children's uuids in the format struct('uuid',<uuid>,'property',<prop>)
    item.children = cobj.getUuids(struct('group','children','format','UuidWithPropNameNoEmpty'));
    % get unidirectional links uuid. same format as children
    item.uniLinks = cobj.getUuids(struct('group','ul','format','UuidWithPropNameNoEmpty'));
    % get bidirectional links uuid. same format as children
    item.biLinks = cobj.getUuids(struct('group','bl','format','UuidWithPropNameNoEmpty'));
    % get parents uuids. just uuid list.
    item.parents = cobj.getUuids('parents');
    
    % insert memory consumption
    item.memory = cobj.getSize(true);

    % insert item in full list
    obj.objList.(muuid) = item;
    
    % populate hierarchical item
    hitem.uuid = cuuid;
    hitem.name = [cobj.type ' ' cuuid];
    hitem.relation = '';
    hitem.parent = '';
    hitem.size = item.memory.total;
    hitem.children = {};    

    % remove it from memory
    if ~inmem
        om.clear(cuuid);
    end %if
        
    if recursive
        % loops on childrens
        for i = 1:length(item.children)
            % prepare hash
            hash = ['pc-' cuuid '-' item.children(i).uuid];
            % check if relation is already in list
            j = find(strcmp(hash,{obj.relList.hash}),1);
            if isempty(j)
                % insert in relation list this relation
                obj.relList(end+1).hash = ['pc-' cuuid '-' item.children(i).uuid];
                obj.relList(end).relation = 'parent-child';
                obj.relList(end).source = cuuid;
                obj.relList(end).dest = item.children(i).uuid;
                obj.relList(end).sProp = item.children(i).prop;
            else
                % relation already in list, update it
                obj.relList(j).prop = item.children(i).prop;
            end %if
            % convert current uuid to matlab accaptable form
            cmuuid = ['uuid_' regexprep(item.children(i).uuid,'-','_')];
            % call itself recursively on this child
            %if ~isfield(obj.objList,cmuuid)
                chitem = obj.ihCrawler( ...
                    item.children(i).uuid, ...
                    ~isfield(obj.objList,cmuuid),...
                    cuuid);
                if isstruct(chitem)
                    % update parent and relation
                    chitem.relation = 'parent-child';
                    chitem.parent = cuuid;
                    % insert child hierarchical item as child
                    hitem.children{length(hitem.children)+1} = chitem;
                end %if
            %end %if
        end %for
    
        % loops on unidirectional links
        for i = 1:length(item.uniLinks)
            % insert in relation list this relation
            obj.relList(end+1).hash = ['ul-' cuuid '-' item.uniLinks(i).uuid];
            obj.relList(end).relation = 'unidirectional-link';
            obj.relList(end).source = cuuid;
            obj.relList(end).dest = item.uniLinks(i).uuid;
            obj.relList(end).sProp = item.uniLinks(i).prop;
            % convert current uuid to matlab accaptable form
            ulmuuid = ['uuid_' regexprep(item.uniLinks(i).uuid,'-','_')];
            % call itself recursively on this child
            chitem = obj.ihCrawler( ...
                item.uniLinks(i).uuid, ...
               false, ...
               cuuid);
                %~isfield(obj.objList,ulmuuid));
            if isstruct(chitem)
               	% update parent and relation
                chitem.relation = 'unidirectional-link';
                chitem.parent = cuuid;
                % insert child hierarchical item as child
                hitem.children{length(hitem.children)+1} = chitem;
            end %if
        end %for
        
        % loops on bidirectional links
        for i = 1:length(item.biLinks)
            % hash to be searched
            hash = ['bl-' item.biLinks(i).uuid '-' cuuid];
            % check if the linked object has already been visited
            j = find(strcmp(cuuid,{obj.relList.hash}),1);
            if isempty(j)
                % insert in relation list this relation
                obj.relList(end+1).hash = ['bl-' cuuid '-' item.biLinks(i).uuid];
                obj.relList(end).relation = 'bidirectional-link';
                obj.relList(end).source = cuuid;
                obj.relList(end).dest = item.biLinks(i).uuid;
                obj.relList(end).sProp = item.biLinks(i).prop;
            else
                % relation already present in list
                obj.relList(j).dProp = itm.biLinks(i).prop;
            end %if
            % convert current uuid to matlab accaptable form
            blmuuid = ['uuid_' regexprep(item.biLinks(i).uuid,'-','_')];
            % call itself recursively on this child
            chitem = obj.ihCrawler( ...
                item.biLinks(i).uuid, ...
                false, ...
                cuuid);
                %~isfield(obj.objList,blmuuid));
            if isstruct(chitem)
                % update parent and relation
                chitem.relation = 'bidirectional-link';
                chitem.parent = cuuid;
                % insert child hierarchical item as child
                hitem.children{length(hitem.children)+1} = chitem;
            end %if
        end %for
    
        % loops on parents
        for i = 1:length(item.parents)
            % build search hash
            hash = ['pc-' item.parents{i} '-' cuuid];
            % check if relation already exists
            j = find(strcmp(hash,{obj.relList.hash}),1);
            if isempty(j)
                % insert in relation list this relation
                obj.relList(end+1).hash = ['pc-' item.parents{i} '-' cuuid];
                obj.relList(end).relation = 'parent-child';
                obj.relList(end).source = item.parents{i};
                obj.relList(end).dest = cuuid;
            end %if
            % convert current uuid to matlab accaptable form
            pmuuid = ['uuid_' regexprep(item.parents{i},'-','_')];
            % call itself recursively on this child
            if ~strcmp(puuid,item.parents{i})
                chitem = obj.ihCrawler( ...
                    item.parents{i}, ...
                    false, ...
                    cuuid);
                    %~isfield(obj.objList,pmuuid));
                if isstruct(chitem)
                    % update parent and relation
                    chitem.relation = 'child-parent';
                    chitem.parent = cuuid;
                    % insert child hierarchical item as child
                    hitem.children{length(hitem.children)+1} = chitem;
                end %if
            end %if
        end %for
    end %if
    
    % remove children key if empty
    if isempty(hitem.children)
        res = rmfield(hitem,'children');
    else
        res = hitem;
    end %if
end %function