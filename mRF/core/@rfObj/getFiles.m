function res = getFiles(obj,filtered)
    % function res = obj.getFiles(filtered)
    %
    % return files settings for the object
    % Filtered argument indicates if the path should
    % returned as it is or needs to be filtered with constants, aka
    % substitute any costant found in it.
    %
    % INPUT
    % - filtered : (boolean) OPTIONAL. Default: true. 
    %
    % Output
    % - res (struct)
    %    .base = base path, if used
    %    .data = path for .mat data file
    %    .metadata = path for .yaml metadata file
    %
    
    % check if user specified filtered or we should use default value
    if nargin < 2 || ~isa(filtered,'logical')
        filtered = true;
    end
    
    % prepare output
    res = struct();
    if filtered
        res.base = rfConf.sfilter(obj.def.rf_files.rf_base);
    else
        res.base = obj.def.rf_files.rf_base;
    end %if
    res.data = obj.getDataFileName(filtered);
    res.metadata = obj.getMetadataFileName(filtered);
    
end %function