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
    
    % get uuid and object from argument passed
    [uParent, oParent] = mdf.getUuidAndObject(parent);
    if isempty(oParent)
        throw(MException('mdfObj:rmParent',['Invalid object or uuid ']));
    end %if
    
    % structure of the mdf_parent array
    % - mdf_uuid
    % - mdf_file
    % - mdf_type
    
    % check if parent is already present
    % get parents uuid
    pUuids = {obj.mdf_def.mdf_parents.mdf_uuid};
    % search for uuid
    iParent = find(strcmp(pUuids,uParent));
    
    % remove parent if needed
    if iParent
        obj.mdf_def.mdf_parents(iParent) = [];
    end %if
    
    res = 1;
end %function