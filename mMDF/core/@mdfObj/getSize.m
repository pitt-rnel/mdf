function res = getSize(obj,details) 
    % function res mdfObj.getSize(details)
    %
    % return the memory size of the current object
    %
    % INPUT
    %  details : (logical) if true, the function will return the detailed
    %            memory consumption. Please see OUTPUT
    %
    % OUTPUT
    %  res : (integer or struct). if details = false, it returns the total
    %        memory footprint of this object instance.
    %        if details = true, it returns a structure with the following
    %        fields: 
    %        * total    : total memory used by the object
    %        * data     : memory used by the data section of the object
    %        * metadata : memory used by the metadata section of the object
    %
    
    % check input
    if nargin < 1
        details = false;
    end %if
    if ~islogical(details)
        details = false;
    end %if
 
    % initialize variables
    total = 0;
    dsize = 0;
    mdsize = 0;

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
        total = total + cpi.bytes;
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
            dsize = dsize + obj.mdf_def.mdf_data.(cdpn).mdf_mem;
       else
            % data property loaded
            cdpv = obj.data.(cdpn);
            % get data property info
            cdpi = whos('cdpv');
            % add memory size to overall object memory
            dsize = dzise + cdpi.bytes;
       end %if
    end %for
    % update total
    total = total + dsize;
    
    % prepare output
    if details
        % get metadata size
        cpv = obj.metadata;
        % get info about metadata
        cpi = whos('cpv');
        % metdata size;
        mdsize = cpi.bytes;
        % output
        res = struct( ...
            'total', total, ...
            'data', dsize, ...
            'metadata', mdsize);
    else
        res = total;
    end %if
end %function
