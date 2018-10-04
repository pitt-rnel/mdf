function start(obj)
    % mdfConf.start(obj)
    %
    % add additional localize values
    % these are keys prefixed with MDF_
    %
    % start selected RNEL db configuration
    %
    
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
            % newer configuration
            %
            % set the database to mongodb
            obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DB = 'MONGODB';
            %
            % check if we need to write yaml metadata file
            YAML = obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.YAML;
            obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.YAML = ...
                ( ( islogical(YAML) && ( YAML == true ) ) | ...
                  ( isnumeric(YAML) && ( YAML ~= 0 ) ) | ...
                  ( ischar(YAML) &&  strcmp(upper(YAML),'TRUE') ) );
            %
            % check if we need to save the data to file or database and
            % which
            switch upper(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DATA)
                case {'MATFILE', 'FILE', 'MAT', 'M'}
                    obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DATA = 'MATFILE';

                case {'DATABASE', 'DB', 'D'}
                	obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION.DATA = 'DATABASE';

                otherwise
                	throw(MException('mdfConf:start',...
                        ['1: Invalid MDF collection data!!!']));
            end %case

        elseif ( isfield(obj.confData.configurations.configuration{i}.constants,'MDF_COLLECTION_TYPE') )
            % <MDF_COLLECTION_TYPE>MIXED, M, V_1_4</MDF_COLLECTION_TYPE>
            % <MDF_COLLECTION_TYPE>DATABASE, DB, V_1_5</MDF_COLLECTION_TYPE>
            % check if type is correct and convert to standard format
            switch upper(obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION_TYPE)
                case {'MIXED', 'M', 'V_1_4'}
                    obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION_TYPE = 'MIXED';
                    obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION = struct( ...
                        'DB' , 'MONGODB', ...
                        'YAML' , true, ...
                        'DATA' , 'MATFILE' ...
                    );

                case {'DATABASE', 'DB', 'V_1_5'}
                    obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION_TYPE = 'DATABASE';
                    obj.confData.configurations.configuration{i}.constants.MDF_COLLECTION = struct( ...
                        'DB' , 'MONGODB', ...
                        'YAML' , false, ...
                        'DATA' , 'DATABASE' ...
                    );
                    
                otherwise
                    throw(MException('mdfConf:start',...
                            ['2: Invalid MDF collection type!!!']));

                end %switch

            else
                % we cannot proceed
                throw(MException('mdfConf:start',...
                    ['3: Configuration missing MDF collection configuration!!!']));
            end %if

    end % for

    % first get the configuration
    C = obj.getC;    
 
    % run startup functions
    %
    % check if we have a user defined start up function
    disp(' - Checking if we need to run user-defined start up function');
    if ( isfield(C,'STARTUP_FUNCTION') && ...
            ~isempty(C.STARTUP_FUNCTION) )
        % try to execute start up function
        try
            if ischar(C.STARTUP_FUNCTION)
                % we got a string defining the function
                funcName = C.STARTUP_FUNCTION;
                % transform it in a function handle
                funcHandle = str2func(funcName);
            elseif isa(C.STARTUP_FUNCTION,'function_handle');
                % we got a function handler
                funcName = func2str(C.STARTUP_FUNCTION);
                funcHandle = C.STARTUP_FUNCTION;
            end
            % run startup function
            funcHandle(obj);
        catch ME
            disp(['...Error: startup function: ' funcName ' threw an error.']);
            simpleExceptionDisplay(ME)
        end
    else
        disp('...Nothing to do!!!');
    end
    
    
end
