function res = fileLoadInfo(file)
    % function res = rfObj.fileLodaInfo(file)
    %
    % loads rfObj object from file
    % it expects a file of type: .yml, .mat, or .h5
    %
    % the file has to have a well defined structure.
    % rfObj checks for the following variables:
    % - rf_def
    % - rf_metadata
    %
    % anything else is discarded.
    %

    % initialize output 
    res = [];

    % check if input file is valid and exists
    if exist(file,'file') == 0
        % invalid file name or file not existing
        return
    end %if

    % get extension of the file name
    [fp,fn,fe] = fileparts(file);

    % make sure that we catch any issue
    try
        % decide how load it
        switch (fe)
            case {'.yml'}
                % we need to load a yaml file
                res = ReadYaml(file);
            case {'.mat', '.h5'}
                % we have a mat or an h5 file
                % load values through matfile function
                tmp1 = matfile(file);
                % transfer what we need
                res = struct( ...
                    'rf_version', tmp1.rf_version, ...
                    'rf_def', tmp1.rf_def, ...
                    'rf_metadata', tmp1.rf_metadata );
         end %switch
    catch
        % nothing to do
        % just in case we re-initialize the output
        res = [];
    end %try/catch

end %function
