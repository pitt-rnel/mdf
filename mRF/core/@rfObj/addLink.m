function res = addLink(obj,prop,link,dir,pos)
    % function res = obj.addLink(prop,link,dir,pos)
    %
    % insert link object under the link property requested at position specified
    %
    % input
    % - prop  = (string) child property to be create and/or populated
    % - link  = (string or rfObj) link object to be inserted under link prop
    %           Optional. If left empty, no object is created, only the
    %           link property placemark
    %           If an rfObj is passed, it extracts uuid automatically and 
    %           if needed, it insert in rfManage
    %           If a uuid is passed, it retrieves the rfObj from rfManage
    % - dir   = link directionality: uni(directional) or bi(directional)
    %           indicates if the link is uni or bi directional.
    % - pos   = (numeric) position in which the link needs to be inserted.
    %           Optional. Default: end+1
    %           Value is contrained to values from 1 to end+1 of the index
    %           of the current length

    % return object 
    res = obj;
    
    % check input arguments
    if nargin < 2 
        throw(MException('rfObj:addLink','Not enough input arguments.'));
    end %if
    
    % check if links structure is present or needs to be created
    % done for backward compatibility
    if ~isfield(obj.def,'rf_links')
        obj.def.rf_links = struct();
    end %if
    if ~isfield(obj.def.rf_links,'rf_fields')
        obj.def.rf_links.rf_fields = {};
    end %if
    if ~isfield(obj.def.rf_links,'rf_types')
        obj.def.rf_links.rf_types = {};
    end %if
    if ~isfield(obj.def.rf_links,'rf_directions')
        obj.def.rf_links.rf_directions = {};
    end %if
    
    
    % check if we need to create prop
    if ( ~any(strcmp(obj.def.rf_links.rf_fields,prop)) )
        % we need to create the new property
        % append at the end of the list
        obj.def.rf_links.rf_fields{end+1} = prop;
        obj.def.rf_links.rf_types{end+1} = [];
        obj.def.rf_links.rf_directions{end+1} = [];
        obj.def.rf_links.(prop) = [];
    end %if
    
    % find the index
    ip = find(strcmp(obj.def.rf_links.rf_fields,prop));
    if isempty(ip)
        throw(MException('rfObj:addLinks','Invalid link property.')); 
    end %if
    
    % check if we have the object to insert or not
    % input argument: obj, prop, link, dir, pos
    if nargin < 3
        % done
        return;
    end %if
    
    % we got link to insert
    % let's check if we have direcitonality
    if nargin <= 3
        dir = 'b';
    else
        % encode directionality
        % u[ni[directional]] = u
        % b[i[directionl]] = b
        switch lower(dir)
            case {'u', 'uni', 'unidirectional'}
                dir = 'u';
            case {'b', 'bi', 'bidirectional'}
                dir = 'b';
            otherwise
                dir = 'b';
        end %switch
    end %if
    
    % we got position
    % let's check if have position too or not
    if nargin <= 4
        % no position, default to 1
        if isfield(obj.def.rf_links,prop)
            pos = length(obj.def.rf_links.(prop))+1;
        else
            pos = 1;
        end %if
    else
        % we got position, check it
        if ~isnumeric(pos) || pos < 0 || pos > length(obj.def.rf_links.(prop))+1
            throw(MException('rfObj:addLinks',['Invalid position (' num2str(pos) ')']));
        end %if
    end %if
    
    if isa(link,'rfObj')
        % input link is an object
        % get uuid and check if it needs to be inserted in memory
        uuid = link.uuid;
        % check if link exists
        olink = rfObj.load(uuid);
        % check if already exists
        if isempty(olink)
            % it's not in memory and not already defined
            % insert new object
            rfm = rfManage.getInstance();
            rfm.insert(link.uuid,link.file,link);
            olink = link;
        else
            % object already present 
            % TO DO: define a object level copy
        end %if
    else
        % just use uuid
        uuid = link;
        % check if link object exist
        olink = rfObj.load(uuid);
        % check if we found the object with the provided uuid
        if isemty(olink)
            throw(MException('rfObj:addLink',['Invalid uuid(' uuid ')']));
        end %if
    end %if
    
    % check if it is the first element
    if ~isfield(obj.def.rf_links,prop) || ...
            isempty(obj.def.rf_links.rf_types{ip}) || ...
            isempty(obj.def.rf_links.rf_directions{ip}) || ...
            length(obj.def.rf_links.(prop)) == 0
        % insert type of new link
        obj.def.rf_links.rf_types{ip} = olink.type;
        % insert direction of new link
        obj.def.rf_links.rf_directions{ip} = dir;
        % insert new link in new property
        obj.def.rf_links.(prop) = struct( ...
            'rf_uuid', olink.uuid, ...
            'rf_type', olink.type, ...
            'rf_direction', dir, ...
            'rf_file', olink.getMFN(false) );
    else
        % check if uuid is already in list
        uuids = {obj.def.rf_links.(prop).rf_uuid};
        i = find(strcmp(uuids,uuid));
        if ~isempty(i)
            throw(MException('rfObj:addLink',['Object with uuid ' uuid ' already inserted']));
        end %if
        % check if type matches the one already present
        if ~strcmp(obj.def.rf_links.rf_types{ip},olink.type)
            throw(MException('rfObj:addLink',['Invalid type ' olink.type '. Link under ' prop ' are of type ' obj.def.rf_links.rf_types{i}]));
        end %if
        % check if type matches the one already present
        if ~strcmp(obj.def.rf_links.rf_directions{ip},dir)
            throw(MException('rfObj:addLink',['Invalid directionality ' dir '. Link under ' prop ' have directionality  ' obj.def.rf_links.rf_directions{i}]));
        end %if
        % we are cleared to insert in position
        
        obj.def.rf_links.(prop) = [ ...
            obj.def.rf_links.(prop)(1:pos-1), ...
            struct( ...
                'rf_uuid', olink.uuid, ...
                'rf_type', olink.type, ...
                'rf_direction', dir, ...
                'rf_file', olink.getMFN(false) ), ...
            obj.def.rf_links.(prop)(pos:end)];
    end %if
    % add this object as parent
    % the mutual relationship is set up by a static property of the rf
    % class.
    %olink.addParent(obj);
    
    % makes sure that the rf_def structure is in sync
    %obj.def.rf_links.rf_fields = 
end %function