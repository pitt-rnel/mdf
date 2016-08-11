function res = getSize(obj) 
    % function res mdfObj.getSize()
    %
    % return the memory size of the current object
 
    % initialize res that total size to 0
    res = 0;

    % get size of all the object properties,
    % except data properties
    %
    % get list of properties
    pl = properties(obj);
    % remove data key
    pl(strcmp(pl,'data')) = [];

    % loop on properties list
    for i = 1:length(pl)
        % extract property
        cpv = obj.(pl{i});
        % current property info
        cpi = whos('cpv');
        % get size of metadata variable
        res = res + cpi.bytes;
    end %for

    % now computes data properties size
    for i = 1:length(obj.mdf_def.mdf_data.mdf_fields)
        % get data property name
        cdpn = obj.mdf_def.mdf_data.mdf_fields{i};
        % check if data property is already loaded
        if ~obj.status.loaded.data.(cdpn)
            % data property not loaded
            % we use the reference stored in the control structure
            % add memory size to result
            res = res + obj.mdf_def.mdf_data.(cdpn).mdf_mem;
       else
            % data property loaded
            cdpv = obj.data.(cdpn);
            % get data property info
            cdpi = whos('cdpv');
            % add memory size to overall object memory
            res = res + cdpi.bytes;
       end %if
    % end for
end %function
