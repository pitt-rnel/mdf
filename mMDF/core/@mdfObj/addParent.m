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
    
    res = false;
    
    % get link uuid and object
    [uParent, oParent] = mdf.getUAO(parent);
    
    % structure of the mdf_parent array
    % - mdf_uuid
    % - mdf_file
    % - mdf_type
    
    % check if parent is already present
    % get parents uuid
    alreadyParent = 0;
    if isstruct(obj.mdf_def.mdf_parents) && ~isempty(fields(obj.mdf_def.mdf_parents))
        % search for uuid in current parents
        alreadyParent = any(strcmp({obj.mdf_def.mdf_parents.mdf_uuid},uParent));
    end %if
    
    % insert parent if needed
    if ~alreadyParent
        if ~isstruct(obj.mdf_def.mdf_parents) || isempty(fields(obj.mdf_def.mdf_parents))
            obj.mdf_def.mdf_parents = struct( ...
                'mdf_uuid', uParent, ...
                'mdf_file', oParent.getMFN(false), ...
                'mdf_type', oParent.type );
        else
            obj.mdf_def.mdf_parents(end+1) = struct( ...
                'mdf_uuid', uParent, ...
                'mdf_file', oParent.getMFN(false), ...
                'mdf_type', oParent.type );
    end %if
    
    res = true;
end %function
