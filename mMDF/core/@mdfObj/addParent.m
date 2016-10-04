function res = addParent(obj,parent)
    % function res = obj.addParent(parent)
    %
    % add parent to current object
    %
    % Input
    % - parent: (string) uuid of the parent object
    %           (mdfObj) parent object
    %
    %
    
    res = 1;
    
    if isa(parent,'mdfObj')
        % input parent is an object
        % get uuid and check if it needs to be inserted in memory
        uuid = parent.uuid;
        % check if child exists
        oParent = mdfObj.load(uuid);
        % check if already exists
        if isempty(oParent)
            % it's not in memory and not already defined
            % insert new object
            mdfm = mdfManage.getInstance();
            mdfm.insert(parent.uuid,parent.getMFN(),parent);
            oParent = parent;
        else
            % object already present 
            % TO DO: define a object level copy
        end %if
    else
        % just use uuid
        uuid = parent;
        % check if child object exist
        oParent = mdfObj.load(uuid);
        % check if we found the object with the provided uuid
        if isemty(oParent)
            throw(MException('mdfObj:addParent',['Invalid uuid(' uuid ')']));
        end %if
    end %if
    
    % structure of the mdf_parent array
    % - mdf_uuid
    % - mdf_file
    % - mdf_type
    
    % check if parent is already present
    % get parents uuid
    alreadyParent = 0;
    if isstruct(obj.mdf_def.mdf_parents) && ~isempty(fields(obj.mdf_def.mdf_parents))
        pUuids = {obj.mdf_def.mdf_parents.mdf_uuid};
        % search for uuid
        alreadyParent = any(strcmp(pUuids,uuid));
    end %if
    
    % insert parent if needed
    if ~alreadyParent
        if ~isstruct(obj.mdf_def.mdf_parents) || isempty(fields(obj.mdf_def.mdf_parents))
            obj.mdf_def.mdf_parents = struct( ...
                'mdf_uuid', uuid, ...
                'mdf_file', oParent.getMFN(false), ...
                'mdf_type', oParent.type );
        else
            obj.mdf_def.mdf_parents(end+1) = struct( ...
                'mdf_uuid', uuid, ...
                'mdf_file', oParent.getMFN(false), ...
                'mdf_type', oParent.type );
    end %if
    
    res = 1;
end %function
