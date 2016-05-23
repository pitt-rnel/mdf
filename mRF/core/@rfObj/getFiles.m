function res = getFiles(obj)
    % function res = obj.getFiles()
    %
    % return files settings for the object
    % res (struct)
    %  .base = base path, if used
    %  .data = path for .mat data file
    %  .metadata = path for .yaml metadata file
    %
    
    % prepare output
    res = struct();
    res.base = obj.def.rf_files.rf_base;
    res.data = obj.getDataFileName();
    res.metadata = obj.getMetadataFileName();
    
end %function