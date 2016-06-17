function res = save(obj)
    % function res = obj.save()
    %
    % save data, metadata and internal info as necessary
    
    % initialize output value
    res = 0;
    
    % get db and manage singleton
    odb = mdfDB.getInstance();
    
    % update version uuid and modified date
    obj.vuuid = mdf.UUID();
    obj.modified = datestr(now,'yyyy-mm-dd HH:MM:SS');
     
    % prepare variables
    mdData = struct( ...
        'mdf_def', obj.mdf_def, ...
        'mdf_metadata', obj.metadata );
    uuid = obj.uuid;
    
    % first updates database
    % check if we need to insert new or if we need to update
    query = ['{ "mdf_def.mdf_uuid" : "' uuid '" }'];
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
            throw(MException('mdfDObj:save','Multiple DB object with same UUID')); 
    end %if
    
    % get metadata file
    mdFile = obj.getMetadataFileName(true);
    % make sure that folder where metadata file lives exists
    [mdDir,~,~] = fileparts(mdFile);
    if ~exist(mdDir,'dir')
        mkdir(mdDir);
    end %if
    % updates metadata yaml file
    WriteYaml(mdFile,mdData);
    
    % than update data file(s)
    dFile = obj.getDataFileName(true);
    % make sure that folder where data file lives exists
    [dDir,~,~] = fileparts(dFile);
    if ~exist(dDir,'dir')
        mkdir(dDir);
    end %if
    % open data file for writing
    mfData = matfile(dFile,'Writable',true);
    % update mdf_def
    mfData.mdf_def = mdData.mdf_def;
    % update metadata
    mfData.mdf_metadata = mdData.mdf_metadata;
    % reset changed property
    obj.status.changed.metadata = 0;
    % updates only data that have been modified
    for i = 1:length(mdData.mdf_def.mdf_data.mdf_fields)
        % get field
        field = mdData.mdf_def.mdf_data.mdf_fields{i};
        % check if data has changed
        if isfield(obj.status.changed.data,field) && obj.status.changed.data.(field)
            % save data property
            mfData.(field) = obj.data.(field);
            % reset changed
            obj.status.changed.data.(field) = 0;
        end %if
    end %for
    % dimiss matfile object
    delete(mfData);
    clear mfData;
    
    % register object with objMenage
    om = mdfManage.getInstance();
    om.insert(uuid,mdFile,obj);

end %function
