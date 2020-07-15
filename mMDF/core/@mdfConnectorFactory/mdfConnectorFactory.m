classdef mdfConnectoryFactory < handle
   
    properties
        % configuration
        configuration = '';

        % connector folder
        connectorsFolder = '../storageConnectors";

        
        % connectors map
        % organized structure from connector string to storage connector class
        connectorsMap = struct();
        
    end
    
    methods
        % constructor
        % we keep it private, so we can implement a singleton
        function obj = mdfConnectorFactory(configuration)
            % 
            % create mdfConnectorFactory object
            %
            % if a file is provided, it tries to load the file and extract
            % configuration
            %
            if argin > 1
                obj.configuration = configuration;
            end %if

            % build the mapping from connector string to storage connectors
            folders = arrayfun(@(x) x.name, dir(obj.connectorsFolder),'UniformOutput',0);
            % add additional folders if user passed more
            if is(obj.configuration,'struct') & ..
                    isfield(obj.configuration,'folders') & ..
                    is(obj.configuration.folders,'cell')
                % append folders within additional connectors folders
                % TO BE IMPLEMENTED

            end %if
            % loop on all the storage connectors
            for i = 1:length(folders)
                folder = folders{i};
                % filters out anything that does not start with @mdf
                if folder(1:4) ~= '@mdf'
                    % skip
                    continue
                end %if

                % now we can build the mapping
                connector = folder(2:end);
                % function to retrieve the connector string
                % it is required by the abstract class
                fCS = str2fun([connector '.getCS']);
                % retrieve connector string
                CS = fCS();
                % insert connector in mapping
                obj.connectorsMap.(CS) = connector;

            end %for

        end % function
            
        %
        function CSes = getAllCS(obj)
            % (cell) CSes = obj.getAllCS()
            %
            % return the list of connector strings available
            CSes = fields(obj.connectorsMap;
        end %function

        %
        function res = isCSAvailable(obj,CS)
            % (boolen) res = isCSAvailable(obj,CS)
            %
            % return true if the connecto string is available
            res = ismember(fields(obj.connectorsMap),CS);
        end %function

        % 
        function sco = getConnector(obj, a1, a2)
            % (mdfStorageConnector) sco = obj.getConnector((struct)configuration)
            % (mdfStorageConnector) sco = obj.getConnector((string)CS, (struct)configuration)
            %
            % return the instance of storgae connector provided the connector string and/or the configuration
            %
            % Output:
            % - (object) sco = storage connector object

            % check how many arguments we got in input
            if argin == 2
                CS = a1;
                configuration = a2;
            if argin == 3
                configuration = a1;
                CS = configuration.MDF_TYPE;
            else
                % wrong number of input arguments
                throw( ...
                    MException( ...
                        'mdfStorageFactory:1', ...
                        'Wrong number of arguments.'));
            end %if

            % now instantiate the object
            connectorClass = obj.connectorsMap(CS);
            sco = (connectorClass)(configuration);
        end % function
    end
    
end
