classdef (Sealed) mdfDB < handle

    properties (Constant)
        % not sure if I still need this yet
    end  

    properties
        % connection info
        habitats = struct( ...
            'byuuids', struct(), ...
            'bytype', struct(), ...
            'byconnector', struct(), ...
            'uuids', {} ...
        );
        %
        % <habitat>
        %  <uuid>1ec528de-f5ee-4ecd-be3f-3fae08ebf65c</uuid>
        %  <name>mdf test files repo</name>
        %  <connector>mdf_yaml</connector>
        %  <type>files</type>
        %  <mode>batch</mode>
        %  <access>rw</access>
        %  <base relative_path_to="DATA_BASE"></base>
        %  <group>vmd</group>
        %  <components>
        %   <component>mdf_all</component>
        %  </components>
        %  <objects>
        %   <object>mdf_all</object>
        %  </objects>
        % </habitat>
        % <habitat>
        %  <uuid>1ec528de-f5ee-4ecd-be3f-3fae18ebf65c</uuid>
        %  <name>mdf test collection 1</name>
        %  <loadOnInit>true</loadOnInit>
        %  <connector>mdf_mongodb</connector>
        %  <type>db</type>
        %  <mode>live</mode>
        %  <access>rw</access>
        %  <host>localhost</host>
        %  <port>27017</port>
        %  <database>mdf_test</database>
        %  <collection>mdf_test_1</collection>
        %  <group>vmd</group>
        %  <components>
        %   <component>mdf_def_metadata</component>
        %  </components>
        %  <objects>
        %   <object>mdf_all</object>
        %  </objects>
        % </habitat>
        %
        configuration = [];
    end

    methods (Access = private)
        function obj = mdfDB
            % nothing to do
        end
    end
    methods (Static)
        function singleObj = getInstance(conf)
            % function singleton = getInstance(conf)
            %
            % return singleton object
            % input
            % - conf: (string) "release". Delete singleton object
            %         none or (string) "mdf" or "auto". use mdfConf habitats
            %         (struct) local configuration (mostly for debug/testing)
            %
            mlock;
            % use a persistent variable to mantain the instance
            persistent localObj
            %
            % check if the persisten object is actually an object and 
            % is valid
            if isempty(localObj) || ~isa(localObj,'mdfDB')
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
	            % get habitats configuration
                    obj.configuration = oc.getHabs(); 
                else
                    % user passed habitats configuration
                    obj.configuration = conf
                end %if
                % check if we need to instantiate connectors
                if nargin > 1 && isa(conf,'char') && strcmp(conf,'auto')
                    % instantiate connectors
                    localObj.init();
                end %if
            else 
                % we got the object
                %
                % check if user is asking us to delete the singleton instance
                if isa(conf,'char') && strcmp(conf,'release')
                    % delete object
                    delete(localObj);
                    localObj = [];
                end %if
            end %if
            
            % return object
            singleObj = localObj;
        end %def getInstance
    end

    methods
        % init function. Instantiate habitats
        res = init(obj);
        % returns the handle to the habitat, given the habitat uuid
        ohab = getH(habuuid);
        ohab = getHab(habuuid);
        ohab = getHabitat(habuuid);
        % returns the handle to the habitats, given the habitat type: db, file
        ohab = getHsbT(habtype);
        ohab = getHabitatsByType(habtype);
        % save function. Internally calls sSave
        res = save(obj,indata)
        % syncronous save function. All the resquested saves are done syncronously (aka right away)
        res = sSave(obj,indata)
        % asyncronous save function. All the requested saves are queued until Aflush is called
        res = aSave(obj,indata)
        % triggers the actions on all the asyncrounous saves queued
        res = aFlush(obj)
        % run multiple queries on habitats
        res = query(obj,indata)
        % syncronously delete objects from habitats
        res = sDelete(obj,indata)
        % run specific operations on habitats. Operation are habitat/connector dependent
        res = sOperations(obj,indata)
        % return the configuration structure used when instantiated the object
        res = getConf(obj)
        % return an array with the handles to the habitats
        res = getHabitats(obj,habuuid)
        % return which habitat accepts what piece of data
        res = assH(obj,indata)
        res = assignHabitats(obj,indata)
        % returns the operations allowed by the habitat requested
        res = getOps(obj,habuuid)
        res = getOperations(obj,habuuid)
    end
    
end

