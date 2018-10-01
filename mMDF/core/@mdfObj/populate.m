function res = populate(obj,data)
    % function res = obj,populate(data)
    %
    % populate object from structure passed
    %
    % input
    % - (struct) data: mdf object structure fully populated
    %            
    % output
    % - (boolean) res: true if completed successfully
    %
    %
    
    res = false;
    
    % uuid
    obj.uuid = data.mdf_def.mdf_uuid;
    % vuuid
    obj.vuuid = data.mdf_def.mdf_vuuid;
    % type
    obj.type = data.mdf_def.mdf_type;
    % def
    obj.mdf_def = data.mdf_def;
    % metadata
    obj.metadata = data.mdf_metadata;
    % if the object is saved without metadata, matlab assigns an empty numeric array
    % we need to check for that and convert to an empty struct, if needed
    if ~isa(obj.metadata,'struct')
        % we dump the content loaded and we assign an empty struct
        obj.metadata = struct();
    end %if
    % create place marks for data properties
    for q = 1:length(data.mdf_def.mdf_data.mdf_fields)
        field = data.mdf_def.mdf_data.mdf_fields{q};
        if isstruct(data.mdf_def.mdf_data.(field).mdf_mem)
            obj.mdf_def.mdf_data.(field).mdf_mem = ...
                str2double(data.mdf_def.mdf_data.(field).mdf_mem.x0x24_numberLong);
        end %if
        obj.data.(field) = [];
        obj.status.loaded.data.(field) = 0;
        obj.status.size.data.(field) = 0;
    end %if
    % convert mdf_parent if needed
    obj.mdf_def.mdf_parents = mdf.c2s(obj.mdf_def.mdf_parents);
    % convert each childrens list if needed
    for j = 1:length(obj.mdf_def.mdf_children.mdf_fields)
        % get the field name
        field = obj.mdf_def.mdf_children.mdf_fields{j};
        % convert the field
        obj.mdf_def.mdf_children.(field) = mdf.c2s(obj.mdf_def.mdf_children.(field));
    end %for
                    
    % convert each link list if needed
    for j = 1:length(obj.mdf_def.mdf_links.mdf_fields)
        % get the field name
        field = obj.mdf_def.mdf_links.mdf_fields{j};
        % convert the field
        obj.mdf_def.mdf_links.(field) = mdf.c2s(obj.mdf_def.mdf_links.(field));
    end %for
                    
    res = true;
end %function