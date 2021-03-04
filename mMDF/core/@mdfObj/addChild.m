function res = addChild(obj,prop,child,pos)
    % function res = obj.addChild(prop,child,pos)
    %
    % insert child under the child property requested at position specified
    %
    % input
    % - prop  = (string) child property to be create and/or populated
    % - child = (string or mdfObj) child to be inserted under child prop
    %           Optional. If left empty, no object is created, only the
    %           child property placemark
    %           If an mdfObj is passed, it extracts uuid automatically and 
    %           if needed, it insert in mdfManage
    %           If a uuid is passed, it retrieves the mdfObj from mdfManage
    % - pos   = (numeric) position in which the child needs to be inserted.
    %           Optional. Default: end+1
    %           Value is contrained to values from 1 to end+1 of the index
    %           of the current length

    % return object 
    res = false;
    
    % check input arguments
    if nargin < 2 
        throw(MException('mdfObj:addChild','Not enough input arguments.'));
    end %if
    
    % check if we need to create prop
    if ( ~any(strcmp(obj.mdf_def.mdf_children.mdf_fields,prop)) )
        % we need to create the new property
        % append at the end of the list
        obj.mdf_def.mdf_children.mdf_fields{end+1} = prop;
        obj.mdf_def.mdf_children.mdf_types{end+1} = [];
        obj.mdf_def.mdf_children.(prop) = [];
    end %if
    % find the index
    ip = find(strcmp(obj.mdf_def.mdf_children.mdf_fields,prop));
    if isempty(ip)
        throw(MException('mdfObj:addChild','Invalid child property.')); 
    end %if
    
    % check if we have the object to insert or not
    if nargin <= 2
        % done
        return;
    end %if
    
    % we got child to insert
    % let's check if have position too or not
    if nargin <= 3
        % no position, default to 1
        if isfield(obj.mdf_def.mdf_children,prop)
            pos = length(obj.mdf_def.mdf_children.(prop))+1;
        else
            pos = 1;
        end %if
    else
        % we got position, check it
        if ~isnumeric(pos) || pos < 0 || pos > length(obj.mdf_def.mdf_children.(prop))+1
            throw(MException('mdfObj:addChild',['Invalid position (' num2str(pos) ')']));
        end %if
    end %if
    
    % get child uuid and object
    [uChild, oChild] = mdf.getUAO(child);
    
    % check if it is the first element
    if ~isfield(obj.mdf_def.mdf_children,prop) || ...
            isempty(obj.mdf_def.mdf_children.mdf_types{ip}) || ...
            length(obj.mdf_def.mdf_children.(prop)) == 0
        % insert type of new child
        obj.mdf_def.mdf_children.mdf_types{ip} = oChild.type;
        % insert new child in new property
        obj.mdf_def.mdf_children.(prop) = struct( ...
            'mdf_uuid', oChild.uuid, ...
            'mdf_type', oChild.type, ...
            'mdf_file', oChild.getMFN(false) );
    else
        % check if uuid is already in list
        uuids = {obj.mdf_def.mdf_children.(prop).mdf_uuid};
        i = find(strcmp(uuids,uChild));
        if ~isempty(i)
            throw(MException('mdfObj:addChild',['Object with uuid ' uChild ' already inserted']));
        end %if
        % check if type matches the one already present
        if ~strcmp(obj.mdf_def.mdf_children.mdf_types{ip},oChild.type)
            throw(MException('mdfObj:addChild',['Invalid type ' oChild.type '. Children under ' prop ' are of type ' obj.mdf_def.mdf_children.mdf_types{ip}]));
        end %if

        %
        % check the size of the property
        propValue = obj.mdf_def.mdf_children.(prop)(:)';
        % we are cleared to insert in position
        obj.mdf_def.mdf_children.(prop) = [ ...
            propValue(1:pos-1), ...
            struct( ...
                'mdf_uuid', oChild.uuid, ...
                'mdf_type', oChild.type, ...
                'mdf_file', oChild.getMFN(false) ), ...
            propValue(pos:end)];
    end %if
    
    res = true;
    
end %function
