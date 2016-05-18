function res = save(obj)
    % function res = obj.save()
    %
    % save data, metadata and internal info as necessary
    
    % initialize output value
    res = 0;
    
    % get db and manage singleton
    odb = rfDB.getInstance();
    
    % update version uuid
    obj.vuuid = rf.UUID();
     
    % prepare variables
    mdData = struct( ...
        'rf_def', obj.def, ...
        'rf_metadata', obj.metadata );
    uuid = obj.uuid;
    
    % first updates database
    % check if we need to insert new or if we need to update
    query = ['{ "rf_def.rf_uuid" : "' uuid '" }'];
    res1 = odb.find(query);
    switch length(res1)
        case 1
            % we are updating
            res2 = odb.update(query,mdData);
        case 0
            % we are inserting new
            res2 = odb.insert(mdData);
        otherwise
            % error: there should only 1 or 0 records
            throw(MException('rfDObj:save','Multiple DB object with same UUID')); 
    end %if
    
    % get metadata file
    mdFile = obj.getMetadataFileName();
    % make sure that folder where metadata file lives exists
    [mdDir,~,~] = fileparts(mdFile);
    if ~exist(mdDir,'dir')
        mkdir(mdDir);
    end %if
    % updates metadata yaml file
    WriteYaml(mdFile,mdData);
    
    % than update data file(s)
    dFile = obj.getDataFileName();
    % make sure that folder where data file lives exists
    [dDir,~,~] = fileparts(dFile);
    if ~exist(dDir,'dir')
        mkdir(dDir);
    end %if
    % open data file for writing
    mfData = matfile(dFile,'Writable',true);
    % update rf_def
    mfData.rf_def = mdData.rf_def;
    % update metadata
    mfData.rf_metadata = mdData.rf_metadata;
    % reset changed property
    obj.status.changed.metadata = 0;
    % updates only data that have been modified
    for i = 1:length(mdData.rf_def.rf_data.rf_fields)
        % get field
        field = mdData.rf_def.rf_data.rf_fields{i};
        % check if data has changed
        if isfield(obj.status.changed.data,field) && obj.status.changed.data.(field)
            % save data property
            mfData.(field) = obj.data.(field);
            % reset changed
            obj.status.changed.data.(field) = 0;
        end %if
    end %for
    
    % register object with objMenage
    om = rfManage.getInstance();
    om.insert(uuid,mdFile,obj);

end %function