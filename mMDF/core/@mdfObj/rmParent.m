function res = rmParent(obj,parent)
    % function res = obj.rmParent(parent)
    %
    % remove object from parent list
    %
    % Input
    % - parent: (string) uuid of the parent object
    %           (mdfObj) parent object
    %
    %
    
    res = 0;
    
    if isa(parent,'mdfObj')
        % input parent is an object
        % get uuid and check if it needs to be inserted in memory
        uuid = parent.uuid;
        % check if child exists
        oparent = mdfObj.load(uuid);
        % check if already exists
        if isempty(oparent)
            % it's not in memory and not already defined
            % insert new object
            mdfm = mdfManage.getInstance();
            mdfm.insert(parent.uuid,parent.file,parent);
            oparent = parent;
        else
            % object already present 
            % TO DO: define a object level copy
        end %if
    else
        % just use uuid
        uuid = parent;
        % check if child object exist
        oparent = mdfObj.load(uuid);
        % check if we found the object with the provided uuid
        if isemty(oparent)
            throw(MException('mdfObj:addParent',['Invalid uuid(' uuid ')']));
        end %if
    end %if
    
    % structure of the mdf_parent array
    % - mdf_uuid
    % - mdf_file
    % - mdf_type
    
    % check if parent is already present
    % get parents uuid
    pUuids = {obj.parents.mdf_uuid};
    % search for uuid
    iParent = find(strcmp(pUuids,uuid));
    
    % insert parent if needed
    if iParent
        obj.parents(iParent) = [];
    end %if
    
    res = 1;
end %function