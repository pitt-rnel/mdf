function res = removeDataProperty(obj,dp)
    % function res = obj.removeDataProperty(dp)
    % 
    % remove metadata field from object's metadata
    % it will remove only the first level field.
    % it does not work on nested fields
    
    res = false;
    
    % remove data property from data structure if loaded
    if isfield(obj.data,dp)
        obj.data = rmfield(obj.data,dp);
    end %if
    
    % remove data property information from mdf_def
    % first: list of fields
    obj.mdf_def.mdf_data.mdf_fields( ...
        strcmp(obj.mdf_def.mdf_data.mdf_fields,dp)) = [];
    % second data field itself
    obj.mdf_def.mdf_data = rmfield(obj.mdf_def.mdf_data,dp);
    
    % indicate that the data property has been deleted
    obj.status.deleted.data.(dp) = true;
    
    res = true;
    
end % function