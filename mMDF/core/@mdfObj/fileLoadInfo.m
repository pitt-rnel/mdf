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
                % fixes few things
                % apparently the size of data is loaded as cell of numbers
                for i1 = 1:length(res.mdf_def.mdf_data.mdf_fields)
                    % get data properties name
                    dpname = res.mdf_def.mdf_data.mdf_fields{i1};
                    % check if size is a cell
                    if iscell(res.mdf_def.mdf_data.(dpname).mdf_size)
                        % we need to convert it to a matrix
                        res.mdf_def.mdf_data.(dpname).mdf_size = ...
                            cell2mat( ...
                                res.mdf_def.mdf_data.(dpname).mdf_size);
                    end %if
                end %for
                res.mdf_from_file = 'yml';
            case {'.mat', '.h5'}
                % we have a mat or an h5 file
                % load values through matfile function
                tmp1 = matfile(file);
                % transfer what we need
                res = struct( ...
                    'mdf_version', '1.4', ...
                    'mdf_def', tmp1.mdf_def, ...
                    'mdf_metadata', tmp1.mdf_metadata );
                if ismember('mdf_version',fields(tmp1))
                    res.mdf_version = tmp1.mdf_version;
                end %if
                if ~isempty(res.mdf_def.mdf_data.mdf_fields)
                    % loads data properties
                    res.mdf_data = struct();
                    for i = 1:length(res.mdf_def.mdf_data.mdf_fields)
                        dp = res.mdf_def.mdf_data.mdf_fields{i};
                        res.mdf_data.(dp) = tmp1.(dp);
                    end %for
                    res.mdf_data_loaded = true;
                end %if
                res.mdf_from_file = 'mat';
         end %switch
    catch
        % nothing to do
        % just in case we re-initialize the output
        res = [];
    end %try/catch

end %function
