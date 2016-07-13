function res = fileLoadInfo(file)
    % function res = mdfObj.fileLodaInfo(file)
    %
    % loads mdfObj object from file
    % it expects a file of type: .yml, .mat, or .h5
    %
    % the file has to have a well defined structure.
    % mdfObj checks for the following variables:
    % - mdf_def
    % - mdf_metadata
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
                    'mdf_version', tmp1.mdf_version, ...
                    'mdf_def', tmp1.mdf_def, ...
                    'mdf_metadata', tmp1.mdf_metadata );
         end %switch
    catch
        % nothing to do
        % just in case we re-initialize the output
        res = [];
    end %try/catch

end %function