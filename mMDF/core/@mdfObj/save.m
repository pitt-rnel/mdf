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
        res = false;
    end %if
    if collect
        res = struct( ...
            'res', false, ...
            'timing' , struct( ...
                'begin', datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') ...
            ) ...
        );
    else
        % initialize output value
        res = false;
    end %if
    
    % get db and manage singleton
    odb = mdfDB.getInstance();
    oconf = mdfConf.getInstance();
    
    % update version uuid and modified date
    obj.vuuid = mdf.UUID();
    obj.modified = datestr(now,'yyyy-mm-dd HH:MM:SS');
     
    % prepare temporary struct to be saved
    objStruct = struct( ...
        'mdf_version', 1, ...
        'mdf_def', obj.mdf_def, ...
        'mdf_metadata', obj.metadata );
    uuid = obj.uuid;
    % initialize file name to na, as mdfManage still require a file name
    mdFile = 'na';
    
    % writes out yaml file if requested
    if oconf.getCollectionYaml()
        if collect
            res.timing.yamlsave = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
        end %if
        % get metadata file
        mdFile = obj.getMetadataFileName(true);
        % make sure that folder where metadata file lives exists
        [mdDir,~,~] = fileparts(mdFile);
        if ~exist(mdDir,'dir')
        	mkdir(mdDir);
        end %if
        % updates metadata yaml file
        WriteYaml(mdFile,objStruct);
    end %if

    % prepare query for selcting the correct object
    query = ['{ "mdf_def.mdf_uuid" : "' uuid '" }'];

    % insert data in query if needed
    if oconf.isCollectionData('DATABASE')
        % insert only data that changed since loading
        for i = 1:length(objStruct.mdf_def.mdf_data.mdf_fields)
            % get field
            field = objStruct.mdf_def.mdf_data.mdf_fields{i};
            % check if data has changed
            if isfield(obj.status.changed.data,field) && obj.status.changed.data.(field)
                % save data property
                objStruct.(field) = obj.data.(field);
                % reset changed
                obj.status.changed.data.(field) = 0;
            end %if
        end %for
    end %if
    
    % first updates database
    if collect
        res.timing.dbsave = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
    end %if
    % we are updating with upsert option
    % if document does not exists in db, it creates a new one
    res2 = odb.update(query,objStruct,true);

    % write to mat file if requested
    if oconf.isCollectionData('MATFILE')
        if collect
            res.timing.matsave = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
        end %if
        % get file name
        dFile = obj.getDataFileName(true);
        % make sure that folder where data file lives exists
        [dDir,~,~] = fileparts(dFile);
        if ~exist(dDir,'dir')
            mkdir(dDir);
        end %if
        % open data file for writing
        mfData = matfile(dFile,'Writable',true);
        % update mdf_def
        mfData.mdf_def = objStruct.mdf_def;
        % update metadata
        mfData.mdf_metadata = objStruct.mdf_metadata;
        % reset changed metadata
        obj.status.changed.metadata = 0;
        % updates only data that have been modified
        for i = 1:length(objStruct.mdf_def.mdf_data.mdf_fields)
            % get field
            field = objStruct.mdf_def.mdf_data.mdf_fields{i};
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
    end %if

    % dimiss temporary struct
    clear objStruct;
    if collect
        res.timing.endsave = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
    end %if

    % register object with objManage
    om = mdfManage.getInstance();
    om.insert(uuid,mdFile,obj);
    if collect
        res.timing.exit = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
        res.res = true && (res2 == 1);
    else
        res = true && (res2 == 1);
    end %if

end %function
