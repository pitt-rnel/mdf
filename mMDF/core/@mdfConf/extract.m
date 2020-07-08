function obj = extract(obj)
    % obj = mdfConf.extract(obj)
    %
    % extract configuration from data extracted from configuration file
    %

    % checks if fileData has data 
    if ( isempty(obj.fileData) )
         throw(MException('mdfConf:extract:1',...
            'No file data available. Please specify configuration file to load!!'));
    end
       
    switch (obj.fileType)
        case 'xml'
            extractXml(obj);
        otherwise
            % nothing to do
            % initialize configuration data
            obj.confData = struct;
    end
    
    %
    % loops on all the configurations and complete them with additional mdf
    % variables
    for i = 1:length(obj.confData.configurations.configuration)
        % add if we need to use json library within matlab or not
        % added for backward compatibility
        if (exist('jsondecode') == 5)
            obj.confData.configurations.configuration{i}.constants.MDF_MATLAB_JSONAPI = true;
            obj.confData.configurations.configuration{i}.constants.MDF_JSONAPI = 'MATLAB';
        else
            obj.confData.configurations.configuration{i}.constants.MDF_MATLAB_JSONAPI = false;
            obj.confData.configurations.configuration{i}.constants.MDF_JSONAPI = 'JSONLAB';
        end %if

        % check if we have the collection configuration
        if ( (isfield(obj.confData.configurations.configuration{i}.constants,'MDF_COLLECTION')) & ...
                (isfield(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION,'YAML')) & ...
                (isfield(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION,'DATA')) )
            % legacy configuration
            %
            % check if we need to covert database/DB
            if ~isfield(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION,'METADATA')
                if isfield(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION,'DB')
                    obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.METADATA = ...
                        obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DB;
                elseif isfield(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION,'DATABASE')
                    obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.METADATA = ...
                        obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DATABASE;
                else
                    obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.METADATA = 'MONGODB';
                end %if
            % set the database to mongodb
            try
                obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.METADATA = ...
                    obj.dcValidation.VALUES.MDF_COLLECTION.DATABASE.(...
                        upper(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.METADATA));
            catch
                throw(MException('mdfConf:start',...
                    ['1: Invalid MDF collection database configuration!!!']));
            end %try/catch
            %
            % check if we need to write yaml metadata file
            YAML = obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.YAML;
            obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.YAML = ...
                ( ( islogical(YAML) && ( YAML == true ) ) | ...
                  ( isnumeric(YAML) && ( YAML ~= 0 ) ) | ...
                  ( ischar(YAML) &&  strcmp(upper(YAML),'TRUE') ) );
            %
            % check if we need to save the data to file or database and
            % which database
            try
                obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DATA = ...
                    obj.dcValidation.VALUES.MDF_COLLECTION.DATA.(...
                        upper(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DATA));
            catch
                throw(MException('mdfConf:start',...
                    ['2: Invalid MDF collection data configuration!!!']));
            end %try/catch
            
            %
            % now converts to new storage system
            if obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DATA ~= "MONGODB_ALL"
                obj.confData.configurations.configuration{i}.constants.MDF_STORAGES = { ...
                    "MONGODB", ...
                    obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DATA};
            else
                obj.confData.configurations.configuration{i}.constants.MDF_STORAGES = { "MONGODB_ALL" };
            end
            %
            % add yaml if needed
            if obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.YAML
                obj.confData.configurations.configuration{i}.constants.MDF_STORAGES{end+1} = "YAML_FILES";
            end %if

        elseif ( isfield(obj.confData.configurations.configuration{i}.constants,'MDF_COLLECTION_TYPE') )
            % <MDF_COLLECTION_TYPE>MIXED, M, V_1_4</MDF_COLLECTION_TYPE>
            % <MDF_COLLECTION_TYPE>DATABASE, DB, V_1_5</MDF_COLLECTION_TYPE>
            % check if type is correct and convert to standard format
            try
                % validate the data collection type
                obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION_TYPE = ...
                    obj.dcValidation.VALUES.MDF_COLLECTION_TYPE.( ...
                    upper(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION_TYPE));
                % expand the configuration for each component
                obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION = ...
                    obj.dcValidation.STRUCTURES.MDF_COLLECTION_TYPE.(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION_TYPE);
            catch
                throw(MException('mdfConf:start',...
                    ['3: Invalid MDF collection type configuration!!!']));
            end %try/catch
            
            %
            % convert to newstorage system
            obj.confData.configurations.configuration{i}.constants.MDF_STORAGES = obj.dcValidation.MDF_STORAGES.MDF_COLLECTION_TYPE.(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION);

        elseif ( isfield(obj.confData.configurations.configuration{i}.constants,'MDF_STORAGES') )
            % check that the values are valid
            for j = 1:length(obj.confData.configurations.configuration{i}.constants.MDF_STORAGES.MDF_STORAGE)
                storage = obj.confData.configurations.configuration{i}.constants.MDF_STORAGES.MDF_STORAGE{j};
                if ~ismember(storage,obj.dcValidation.VALUES.MDF_STORAGES)
                    throw(MException('mdfConf:start',...
                        ['4: Configuration with invalid mdf storage value!!!']));
                end %if
            end %for
            
        else
            % we cannot proceed
            throw(MException('mdfConf:start',...
            	['5: Configuration missing MDF collection configuration!!!']));
        end %if

    end % for


end
