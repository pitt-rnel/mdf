function res = removeMetadataField(obj,field)
    % function res = obj.removeMetadataField(field)
    % 
    % remove metadata field from object's metadata
    % it will remove only the first level field.
    % it does not work on nested fields
    
    res = false;
    
    obj.metadata = rmfield(obj.metadata,field);
    
    res = true;
    
end %function