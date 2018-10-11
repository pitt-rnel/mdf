function dfn = getDataFileName(obj,filtered)
    % function dfn = obj.getDataFileName()
    %
    % returns the filename containing the data properties for this object
    % false if not defined. Filtered argument indicates if the path should
    % returned as it is or needs to be filtered with constants, aka
    % substitute any costant found in it.
    %
    % INPUT
    % - filtered : (boolean) OPTIONAL. Default: true. 
    %
    
    % initialize output
    dfn = false;

    % get conf singleton
    oconf = mdfConf.getInstance();

    % check if user specified filtered or we should use default value
    if nargin < 2 || ~isa(filtered,'logical')
        filtered = true;
    end
 
    if oconf.isCollectionData('MATFILE')
        if isfield(obj.mdf_def.mdf_files,'mdf_data') && ...
                ~isempty(obj.mdf_def.mdf_files.mdf_data)
            % exists a file name for data
            dfn = obj.mdf_def.mdf_files.mdf_data;
        else
            % file name for data does not exists yet
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
            dfn = [obj.mdf_def.mdf_files.mdf_base '.data.mat'];
            obj.mdf_def.mdf_files.mdf_data = dfn;
        end %if
        
        % filters if needed
        if filtered
            dfn = mdfConf.sfilter(dfn);
        end %if
    
        % set correct file separator
        dfn = strjoin(strsplit(dfn,{'\','/'}),filesep);
    else
        % we don't use yaml file in data collection
        % just to be sure, we set to empty string
        obj.mdf_def.mdf_files.mdf_data = '';
    end %if
end %function