classdef (Sealed) mdfDB < handle

    properties (Constant)
        % not sure if I still need this yet
    end  

    properties
        % containers info
        containers = struct();
        configuration = [];
    end

    methods (Access = private)
        function obj = mdfDB
            % nothing to do
        end
    end
    methods (Static)
        function obj = getInstance(conf)
            % function singleton = getInstance(conf)
            %
            % return singleton object
            % input
            % - conf: (string) "release". Delete singleton object
            %         none or (string) "mdf" or "auto". use mdfConf habitats
            %         (struct) local configuration (mostly for debug/testing)
            %

            % 
            % we check if the global place maker for mdf exists and if it has a valid mdfConf in it
            global omdfc;
            if ~isstruct(omdfc)
                omdfc = struct();
            end %if

            if ~isfield(omdfc,'db')
                omdfc.db  = [];
            end %if

            % we got the object
            %
            % check if user is asking us to delete the singleton instance
            if isa(conf,'char') && strcmp('release',lower(conf))
                % delete object if it is the right class
                if isa(omdfc.db,'mdfDB')
                    delete(omdfc.db);
                end %if
                omdfc.db = [];
            elseif isempty(omdfc.db) || ~isa(omdfc.db,'mdfDB')
                % no object yet
                %
                % instantiate new object
                localObj = mdfDB;
                %
                % get configuration and populate
                if nargin < 1 || ( ...
                        isa(conf,'char') && ( ...
                            strcmp(conf,'mdf') || ...
                            strcmp(conf,'auto') ) )
                    % user did not provide a configuration
                    % get mdfConf object
                    oc = mdfConf.getInstance();
                    %
	            % get containers configuration as it is specified in configuration
                    omdfc.db.configuration = oc.getConts(); 
                else
                    % user passed habitats configuration
                    omdfc.db.configuration = conf
                end %if
                % check if we need to instantiate connectors
                if nargin > 1 && isa(conf,'char') && strcmp(conf,'auto')
                    % instantiate connectors
                    omdfc.db.init();
                end %if
            else 
                % return reference to db instance
                obj = omdfc.db;
            end %if
        end %def getInstance
    end

    methods
        % init function. Instantiate connectors
        res = init(obj);
        % instantiate a connector and connect to the container
        res = connect(obj,id);
        % disconnect from container and remove connector instance
        res = disconnect(obj,id);

        % returns the handle to the container
        oC = getCont(obj,id);
        % return an array with the handles to the habitats
        oCs = getConts(obj)
        % return the configuration structure used when instantiated the object
        C = getConf(obj)
        % return all the available operations within the specific container/connector
        ops = getOps(obj,id)
        % return container uuid(s) from uuid, human name, machine name or connector type
        uuids = getContainerUuid(obj,id)
        % return true if the container is active 
        % (aka the connection with the backend is open)
        res = isConnected(obj,id)
        
        % save function for backward compatibility. Internally calls sSave
        res = save(obj,indata)
        % syncronous save function. All the resquested saves are done syncronously (aka right away)
        res = sSave(obj,indata)
        % asyncronous save function. 
        % All the requested saves are queued until Aflush is called
        res = aSave(obj,indata)
        % triggers the actions on all the asyncrounous saves queued
        res = aFlush(obj)
        % run multiple queries on habitats
        res = query(obj,indata)
        % syncronously delete objects from containers
        res = sDelete(obj,indata)
        % asyncronously delete objects from containers. 
        % All the requestes are queued until aFlush is called
        res = aDelete(obj,indata)
        % run specific operations on containers. Operation are container/connector dependent
        res = sOps(obj,indata)
    end %methods
    
end %class

