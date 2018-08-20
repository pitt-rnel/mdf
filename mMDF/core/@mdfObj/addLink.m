function res = addLink(obj,prop,link,dir,pos)
    % function res = obj.addLink(prop,link,dir,pos)
    %
    % insert link object under the link property requested at position specified
    %
    % input
    % - prop  = (string) child property to be create and/or populated
    % - link  = (string or mdfObj) link object to be inserted under link prop
    %           Optional. If left empty, no object is created, only the
    %           link property placemark
    %           If an mdfObj is passed, it extracts uuid automatically and 
    %           if needed, it insert in mdfManage
    %           If a uuid is passed, it retrieves the mdfObj from mdfManage
    % - dir   = link directionality: uni(directional) or bi(directional)
    %           indicates if the link is uni or bi directional.
    % - pos   = (numeric) position in which the link needs to be inserted.
    %           Optional. Default: end+1
    %           Value is contrained to values from 1 to end+1 of the index
    %           of the current length

    % return object 
    res = false;
    
    % check input arguments
    if nargin < 2 
        throw(MException('mdfObj:addLink','Not enough input arguments.'));
    end %if
    
    % check if links structure is present or needs to be created
    % done for backward compatibility
    if ~isfield(obj.mdf_def,'mdf_links')
        obj.mdf_def.mdf_links = struct();
    end %if
    if ~isfield(obj.mdf_def.mdf_links,'mdf_fields')
        obj.mdf_def.mdf_links.mdf_fields = {};
    end %if
    if ~isfield(obj.mdf_def.mdf_links,'mdf_types')
        obj.mdf_def.mdf_links.mdf_types = {};
    end %if
    if ~isfield(obj.mdf_def.mdf_links,'mdf_directions')
        obj.mdf_def.mdf_links.mdf_directions = {};
    end %if
    
    
    % check if we need to create prop
    if ( ~any(strcmp(obj.mdf_def.mdf_links.mdf_fields,prop)) )
        % we need to create the new property
        % append at the end of the list
        obj.mdf_def.mdf_links.mdf_fields{end+1} = prop;
        obj.mdf_def.mdf_links.mdf_types{end+1} = [];
        obj.mdf_def.mdf_links.mdf_directions{end+1} = [];
        obj.mdf_def.mdf_links.(prop) = [];
    end %if
    
    % find the index
    ip = find(strcmp(obj.mdf_def.mdf_links.mdf_fields,prop));
    if isempty(ip)
        throw(MException('mdfObj:addLinks','Invalid link property.')); 
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
        if isfield(obj.mdf_def.mdf_links,prop)
            pos = length(obj.mdf_def.mdf_links.(prop))+1;
        else
            pos = 1;
        end %if
    else
        % we got position, check it
        if ~isnumeric(pos) || pos < 0 || pos > length(obj.mdf_def.mdf_links.(prop))+1
            throw(MException('mdfObj:addLinks',['Invalid position (' num2str(pos) ')']));
        end %if
    end %if
    
    % get link uuid and object
    [uLink, oLink] = mdf.getUAO(link);
    
    % check if it is the first element
    if ~isfield(obj.mdf_def.mdf_links,prop) || ...
            isempty(obj.mdf_def.mdf_links.mdf_types{ip}) || ...
            isempty(obj.mdf_def.mdf_links.mdf_directions{ip}) || ...
            length(obj.mdf_def.mdf_links.(prop)) == 0
        % insert type of new link
        obj.mdf_def.mdf_links.mdf_types{ip} = oLink.type;
        % insert direction of new link
        obj.mdf_def.mdf_links.mdf_directions{ip} = dir;
        % insert new link in new property
        obj.mdf_def.mdf_links.(prop) = struct( ...
            'mdf_uuid', oLink.uuid, ...
            'mdf_type', oLink.type, ...
            'mdf_direction', dir, ...
            'mdf_file', oLink.getMFN(false) );
    else
        % check if uuid is already in list
        uuids = {obj.mdf_def.mdf_links.(prop).mdf_uuid};
        i = find(strcmp(uuids,uLink));
        if ~isempty(i)
            throw(MException('mdfObj:addLink',['Object with uuid ' uuid ' already inserted']));
        end %if
        % check if type matches the one already present
        if ~strcmp(obj.mdf_def.mdf_links.mdf_types{ip},oLink.type)
            throw(MException('mdfObj:addLink',['Invalid type ' oLink.type '. Link under ' prop ' are of type ' obj.mdf_def.mdf_links.mdf_types{i}]));
        end %if
        % check if type matches the one already present
        if ~strcmp(obj.mdf_def.mdf_links.mdf_directions{ip},dir)
            throw(MException('mdfObj:addLink',['Invalid directionality ' dir '. Link under ' prop ' have directionality  ' obj.mdf_def.mdf_links.mdf_directions{i}]));
        end %if
        % we are cleared to insert in position
        
        t1 = obj.mdf_def.mdf_links.(prop)(1:pos-1);
        t2 = obj.mdf_def.mdf_links.(prop)(pos:end); 
        obj.mdf_def.mdf_links.(prop) = [ ...
            t1(:); ...
            struct( ...
                'mdf_uuid', oLink.uuid, ...
                'mdf_type', oLink.type, ...
                'mdf_direction', dir, ...
                'mdf_file', oLink.getMFN(false) ); ...
            t2(:)];
    end %if
    
    res = true;
end %function
