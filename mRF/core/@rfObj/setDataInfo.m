function setDataInfo(obj,field)
    % function obj.setDataInfo(field)
    %
    % update properties info in def structure for the field passed
    % input
    %  - field: data property to be updated
    % 
    %
    
    % get info about the specific field
    tmp1 = rfObj.propInfo(obj.data.(field));
    % check if info have changed, 
    % if so, mark rf_def changed
    if ~isfield(obj.def.rf_data,field) || ...
            ~strcmp(obj.def.rf_data.(field).rf_class, tmp1.class) || ...
            ~all(obj.def.rf_data.(field).rf_size == tmp1.size) || ...
            obj.def.rf_data.(field).rf_mem ~= tmp1.bytes
        obj.status.changed.data.(field) = 1;
    end %if
    % set info in the _rf_Def structure
    obj.def.rf_data.(field) = builtin( ...
    	'struct', ...
        'rf_class', tmp1.class, ...
        'rf_size', tmp1.size, ...
        'rf_mem', tmp1.bytes);
end %function