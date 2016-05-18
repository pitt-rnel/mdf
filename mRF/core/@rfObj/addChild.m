function res = addChild(obj,prop,child,pos)
    % function res = obj.addChild(prop,child,pos)
    %
    % insert child under the child property requested at position specified
    %
    % input
    % - prop  = (string) child property to be create and/or populated
    % - child = (string or rfObj) child to be inserted under child prop
    %           Optional. If left empty, no object is created, only the
    %           child property placemark
    %           If an rfObj is passed, it extracts uuid automatically and 
    %           if needed, it insert in rfManage
    %           If a uuid is passed, it retrieves the rfObj from rfManage
    % - pos   = (numeric) position in which the child needs to be inserted.
    %           Optional. Default: end+1
    %           Value is contrained to values from 1 to end+1 of the index
    %           of the current length

    % return object 
    res = obj;
    
    % check input arguments
    if nargin < 2 
        throw(MException('rfObj:addChild','Not enough input arguments.'));
    end %if
    
    % check if we need to create prop
    if ( ~any(strcmp(obj.def.rf_children.rf_fields,prop)) )
        % we need to create the new property
        % append at the end of the list
        obj.def.rf_children.rf_fields{end+1} = prop;
        obj.def.rf_children.rf_types{end+1} = [];
        obj.def.rf_children.(prop) = [];
    end %if
    % find the index
    ip = find(strcmp(obj.def.rf_children.rf_fields,prop));
    if isempty(ip)
        throw(MException('rfObj:addChild','Invalid child property.')); 
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
        if isfield(obj.def.rf_children,prop)
            pos = length(obj.def.rf_children.(prop))+1;
        else
            pos = 1;
        end %if
    else
        % we got position, check it
        if ~isnumeric(pos) || pos < 0 || pos > length(obj.def.rf_children.(prop))+1
            throw(MException('rfObj:addChild',['Invalid position (' num2str(pos) ')']));
        end %if
    end %if
    
    if isa(child,'rfObj')
        % input child is an object
        % get uuid and check if it needs to be inserted in memory
        uuid = child.uuid;
        % check if child exists
        ochild = rfObj.load(uuid);
        % check if already exists
        if isempty(ochild)
            % it's not in memory and not already defined
            % insert new object
            rfm = rfManage.getInstance();
            rfm.insert(child.uuid,child.file,child);
            ochild = child;
        else
            % object already present 
            % TO DO: define a object level copy
        end %if
    else
        % just use uuid
        uuid = child;
        % check if child object exist
        ochild = rfObj.load(uuid);
        % check if we found the object with the provided uuid
        if isemty(ochild)
            throw(MException('rfObj:addChild',['Invalid uuid(' uuid ')']));
        end %if
    end %if
    
    % check if it is the first element
    if ~isfield(obj.def.rf_children,prop) || ...
            isempty(obj.def.rf_children.rf_types{ip}) || ...
            length(obj.def.rf_children.(prop)) == 0
        % insert type of new child
        obj.def.rf_children.rf_types{ip} = ochild.type;
        % insert new child in new property
        obj.def.rf_children.(prop) = struct( ...
            'rf_uuid', ochild.uuid, ...
            'rf_type', ochild.type, ...
            'rf_file', ochild.file );
    else
        % check if uuid is already in list
        uuids = {obj.def.rf_children.(prop).rf_uuid};
        i = find(strcmp(uuids,uuid));
        if ~isempty(i)
            throw(MException('rfObj:addChild',['Object with uuid ' uuid ' already inserted']));
        end %if
        % check if type matches the one already present
        if ~strcmp(obj.def.rf_children.rf_types{ip},ochild.type)
            throw(MException('rfObj:addChild',['Invalid type ' ochild.type '. Children under ' prop ' are of type ' obj.def.rf_children.rf_types{i}]));
        end %if
        % we are cleared to insert in position
        
        obj.def.rf_children.(prop) = [ ...
            obj.def.rf_children.(prop)(1:pos-1), ...
            struct( ...
                'rf_uuid', ochild.uuid, ...
                'rf_type', ochild.type, ...
                'rf_file', ochild.file ), ...
            obj.def.rf_children.(prop)(pos:end)];
    end %if
    % add this object as parent
    % the mutual relationship is set up by a static property of the rf
    % class.
    %ochild.addParent(obj);
    
    % makes sure that the rf_def structure is in sync
    %obj.def.rf_children.rf_fields = 
end %function