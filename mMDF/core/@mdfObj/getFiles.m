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
    
    % get conf singleton
    oconf = mdfConf.getInstance();
    
    % check if user specified filtered or we should use default value
    if nargin < 2 || ~isa(filtered,'logical')
        filtered = true;
    end
    
    % prepare output
    res = struct();
    res.data = obj.getDataFileName(filtered);
    res.metadata = obj.getMetadataFileName(filtered);
    res.base = false;
    if oconf.isCollectionData('MATFILE') || oconf.getCollectionYaml()
        if filtered
            res.base = mdfConf.sfilter(obj.mdf_def.mdf_files.mdf_base);
        else
            res.base = obj.mdf_def.mdf_files.mdf_base;
        end %if
    else
        obj.mdf_def.mdf_files.mdf_base = '';
    end %if

end %function