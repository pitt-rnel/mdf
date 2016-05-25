function res = addParent(obj,parent)
    % function res = obj.addParent(parent)
    %
    % add parent to current object
    %
    % Input
    % - parent: (string) uuid of the parent object
    %           (rfObj) parent object
    %
    %
    
    res = 1;
    
    if isa(parent,'rfObj')
        % input parent is an object
        % get uuid and check if it needs to be inserted in memory
        uuid = parent.uuid;
        % check if child exists
        oParent = rfObj.load(uuid);
        % check if already exists
        if isempty(oParent)
            % it's not in memory and not already defined
            % insert new object
            rfm = rfManage.getInstance();
            rfm.insert(parent.uuid,parent.getMFN(),parent);
            oParent = parent;
        else
            % object already present 
            % TO DO: define a object level copy
        end %if
    else
        % just use uuid
        uuid = parent;
        % check if child object exist
        oParent = rfObj.load(uuid);
        % check if we found the object with the provided uuid
        if isemty(oParent)
            throw(MException('rfObj:addParent',['Invalid uuid(' uuid ')']));
        end %if
    end %if
    
    % structure of the rf_parent array
    % - rf_uuid
    % - rf_file
    % - rf_type
    
    % check if parent is already present
    % get parents uuid
    alreadyParent = 0;
    if ~isempty(fields(obj.def.rf_parents))
        pUuids = {obj.def.rf_parents.rf_uuid};
        % search for uuid
        alreadyParent = any(strcmp(pUuids,uuid));
    end %if
    
    % insert parent if needed
    if ~alreadyParent
        if isempty(fields(obj.def.rf_parents))
            obj.def.rf_parents = struct( ...
                'rf_uuid', uuid, ...
                'rf_file', oParent.getMFN(false), ...
                'rf_type', oParent.type );
        else
            obj.def.rf_parents(end+1) = struct( ...
                'rf_uuid', uuid, ...
                'rf_file', oParent.getMFN(false), ...
                'rf_type', oParent.type );
    end %if
    
    res = 1;
end %function