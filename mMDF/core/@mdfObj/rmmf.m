function res = rmmf(obj,field)
    % function res = obj.rmmf(field)
    % 
    % remove metadata field from object's metadata
    % please refer to mdfObj.removeMetadataField for more info
    
    res = obj.removeMetadataField(field);
    
end %function