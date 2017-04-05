function res = save(obj, tf)
    % function res = obj.save(tf)
    %
    % save data, metadata and internal info as necessary
    %
    % input
    % - tf : boolean indicating if we want timing info
    %
    % output:
    % - res : result of the operation, if timing is false
    %       : struct containing results of the operation and 
    %         timing of the different operations

    % check if we need to keep track of the time
    collect = false;
    if ( nargin > 1 )
        collect = (tf == true );
        res = 0;
    end %if
    if collect
        res = struct( ...
            'res', 0, ...
            'timing' , struct( ...
                'begin', datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ...
            ) ...
        );
    else
        % initialize output value
        res = 0;
    end %if
    
    % get db and manage singleton
    odb = mdfDB.getInstance();
    
    % update version uuid and modified date
    obj.vuuid = mdf.UUID();
    obj.modified = datestr(now,'yyyy-mm-dd HH:MM:SS');
     
    % prepare temporary struct to be saved to db
    dbStruct = struct( ...
        'mdf_def', obj.mdf_def, ...
        'mdf_metadata', obj.metadata );
    uuid = obj.uuid;
    % prepare query for selcting the correct object
    query = ['{ "mdf_def.mdf_uuid" : "' uuid '" }'];

    % updates only data that have been
    for i = 1:length(dbStruct.mdf_def.mdf_data.mdf_fields)
        % get field
        field = dbStruct.mdf_def.mdf_data.mdf_fields{i};
        % check if data has changed
        if isfield(obj.status.changed.data,field) && obj.status.changed.data.(field)
            % save data property
            dbStruct.(field) = obj.data.(field);
            % reset changed
            obj.status.changed.data.(field) = 0;
        end %if
    end %for
    
    % first updates database
    if collect
        res.timing.dbsave = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
    end %if
    % we are updating with upsert option
    % if document does not exists in db, it creates a new one
    res2 = odb.update(query,dbStruct,true);
    
    % dimiss temporary struct
    clear dbStruct;
    if collect
        res.timing.endsave = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
    end %if
    
    % register object with objManage
    om = mdfManage.getInstance();
    om.insert(uuid,'na',obj);
    if collect
        res.timing.exit = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
        res.res = 1;
    else
        res = 1;
    end %if

end %function
