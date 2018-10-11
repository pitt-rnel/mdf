function mfn = getMetadataFileName(obj,filtered)
    % function mfn = obj.getMetadataFileName(filtered)
    %
    % returns the filename containing the metadata properties for this object
    % false if not defined. Filtered argument indicates if the path should
    % returned as it is or needs to be filtered with constants, aka
    % substitute any costant found in it.
    %
    % INPUT
    % - filtered : (boolean) OPTIONAL. Default: true. 
    %
    
    % initialize output
    mfn = false;
    
    % get conf singleton
    oconf = mdfConf.getInstance();
    
    % check if user specified filtered or we should use default value
    if nargin < 2 || ~isa(filtered,'logical')
        filtered = true;
    end
    
    if oconf.getCollectionYaml()
        if isfield(obj.mdf_def.mdf_files,'mdf_metadata') && ...
                ~isempty(obj.mdf_def.mdf_files.mdf_metadata)
            % exists a file name for metadata
            mfn = obj.mdf_def.mdf_files.mdf_metadata;
        else
            % file name for metadata does not exists yet
            if ~isfield(obj.mdf_def.mdf_files,'mdf_base') || ...
                    isempty(obj.mdf_def.mdf_files.mdf_base)
                % base file path does not exists yet either
                % assign default one
                %obj.mdf_def.mdf_files.mdf_base = fullfile('<DATA_BASE>',['mdfobj.' obj.uuid]);
                obj.mdf_def.mdf_files.mdf_base = ...
                    fullfile( ...
                        '<DATA_BASE>', ...
                        lower(obj.type), ...
                        [obj.type '_' obj.uuid]);
            end %if
            % use basename to build data file name
            mfn = [obj.mdf_def.mdf_files.mdf_base '.md.yml'];
            obj.mdf_def.mdf_files.mdf_metadata = mfn;
        end %if
    
        % filters if needed
        if filtered
            mfn = mdfConf.sfilter(mfn);
        end %if
    
        % seth correct file separator
        mfn = strjoin(strsplit(mfn,{'\','/'}),filesep);
    else
        % we don't use yaml file in data collection
        % just to be sure, we set to empty string
        obj.mdf_def.mdf_files.mdf_metadata = '';
    end %if
end %function