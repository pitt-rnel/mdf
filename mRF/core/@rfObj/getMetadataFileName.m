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
    
    % check if user specified filtered or we should use default value
    if nargin < 2 || ~isa(filtered,'logical')
        filtered = true;
    end
    
    if isfield(obj.def.rf_files,'rf_metadata') && ...
            ~isempty(obj.def.rf_files.rf_metadata)
        % exists a file name for metadata
        mfn = obj.def.rf_files.rf_metadata;
    elseif isfield(obj.def.rf_files,'rf_base') && ...
            ~isempty(obj.def.rf_files.rf_base)
        % use basename to build data file name
        mfn = [obj.def.rf_files.rf_base '.md.yml'];
        obj.def.rf_files.rf_metadata = mfn;
    end %if
    
    % filters if needed
    if filtered
        mfn = rfConf.sfilter(mfn);
    end %if
end %function