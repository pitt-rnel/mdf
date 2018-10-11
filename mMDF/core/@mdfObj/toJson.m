function jsonString = toJson(obj)
    % function jsonString = obj.toJson()
    %
    % returns the json string for the current object
    %
    
    % create struct to be fed in the json converter
    jsonStruct = struct( ...
        'mdf_version', 1, ...
        'mdf_def', struct(), ...
        'mdf_metadata', struct());
    
    % populates the structure
    jsonStruct.mdf_def = obj.mdf_def;
    jsonStruct.mdf_metadata = obj.metadata;
    dps = obj.mdf_def.mdf_data.mdf_fields;
    for i = 1:length(dps)
        % data property name
        dp = dps{i};
        % makes sure that data property is loaded
        obj.dataLoad(dp);
        % transfer data property
        jsonStruct.(dp) = obj.data.(dp);
    end %for
    
    % returns json string
    jsonString = mdf.toJson(jsonStruct);

end %function