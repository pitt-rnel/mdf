function dfn = getDataFileName(obj)
    % function dfn = obj.getDataFileName()
    %
    % returns the filename containing the data properties for this object
    % false if not defined
    %
    
    % initialize output
    dfn = false;
    
    if isfield(obj.def.rf_files,'rf_data') && ...
            ~isempty(obj.def.rf_files.rf_data)
        % exists a file name for data
        dfn = obj.def.rf_files.rf_data;
    elseif isfield(obj.def.rf_files,'rf_base') && ...
            ~isempty(obj.def.rf_files.rf_base)
        % use basename to build data file name
        dfn = [obj.def.rf_files.rf_base '_data.mat'];
        obj.def.rf_files.rf_data = dfn;
    end %if
end %function