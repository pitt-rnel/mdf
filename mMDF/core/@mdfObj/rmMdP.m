function res = rmMdP(obj,field)
    % function res = obj.rmmf(field)
    % 
    % remove metadata field from object's metadata
    % please refer to mdfObj.removeMetadataField for more info
    
    res = obj.removeMetadataProperty(field);
    
end %function