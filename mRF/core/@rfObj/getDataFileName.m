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
    
    % check if user specified filtered or we should use default value
    if nargin < 2 || ~isa(filtered,'logical')
        filtered = true;
    end
    
    if isfield(obj.def.rf_files,'rf_data') && ...
            ~isempty(obj.def.rf_files.rf_data)
        % exists a file name for data
        dfn = obj.def.rf_files.rf_data;
    elseif isfield(obj.def.rf_files,'rf_base') && ...
            ~isempty(obj.def.rf_files.rf_base)
        % use basename to build data file name
        dfn = [obj.def.rf_files.rf_base '.data.mat'];
        obj.def.rf_files.rf_data = dfn;
    end %if
    
    % filters if needed
    if filtered
        dfn = rfConf.sfilter(dfn);
    end %if
end %function