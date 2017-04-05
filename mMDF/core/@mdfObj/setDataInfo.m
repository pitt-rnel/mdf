function setDataInfo(obj,field)
    % function obj.setDataInfo(field)
    %
    % update properties info in def structure for the field passed
    % input
    %  - field: data property to be updated
    % 
    %
    
    % get info about the specific field
    tmp1 = mdfObj.propInfo(obj.data.(field));
    % check if info have changed, 
    % if so, mark mdf_def changed
    if ~isfield(obj.mdf_def.mdf_data,field) || ...
            ~strcmp(obj.mdf_def.mdf_data.(field).mdf_class, tmp1.class) || ...
            ~all(obj.mdf_def.mdf_data.(field).mdf_size == tmp1.size) || ...
            obj.mdf_def.mdf_data.(field).mdf_mem ~= tmp1.bytes
        obj.status.changed.data.(field) = 1;
    end %if
    % set info in the _mdf_Def structure
    obj.mdf_def.mdf_data.(field) = builtin( ...
    	'struct', ...
        'mdf_class', tmp1.class, ...
        'mdf_size', tmp1.size, ...
        'mdf_mem', tmp1.bytes);
end %function