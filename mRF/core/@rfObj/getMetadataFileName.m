function mfn = getMetadataFileName(obj)
    % function mfn = obj.getMetadataFileName()
    %
    % returns the filename containing the metadata properties for this object
    % false if not defined
    %
    
    % initialize output
    mfn = false;
    
    if isfield(obj.def.rf_files,'rf_metadata') && ...
            ~isempty(obj.def.rf_files.rf_metadata)
        % exists a file name for metadata
        mfn = obj.def.rf_files.rf_metadata;
    elseif isfield(obj.def.rf_files,'rf_base') && ...
            ~isempty(obj.def.rf_files.rf_base)
        % use basename to build data file name
        mfn = [obj.def.rf_files.rf_base '_md.yml'];
        obj.def.rf_files.rf_metadata = mfn;
    end %if
end %function