classdef mdfDBTest < matlab.unittest.TestCase
    % 
    % unit tests for mdfDB
    %
    % load database class, instantiate connectors classes and test
    %

    % properties
    properties
        configuration = '';
        testFolder = '';
    end %properties
    
    methods (TestClassSetup)
        %
        function addMdfPath(testCase)
            % add path to core mdf classes
            % get current path settings
            p = path;
            % set up tear down function to restore path as it was before
            % test
            testCase.addTeardown(@path,p);
            %
            % locate current file and current path
            cffp = mfilename('fullpath');
            [cpfp,~,~] = fileparts(cffp);
            testCase.testFolder = cpfp;
            % add path to core classes of mdf
            addpath(fullfile(cpfp,'..','..','core'));
            % add path to libs
            addpath(fullfile(cpfp,'..','..','libs','jsonlab'));
        end %function

        %
        function defineTestObject(testCase)
            % prepare test values
            %
            % set test configuration
            testCase.configuration = struct( ...
                 'human_name', 'mdfDB test collection 1', ...
                 'machine_name', 'metadata_test_collection_1', ...
                 'host' ,'127.0.0.1', ...
                 'port', 15213, ...
                 'database', 'mdfDbTest', ...
                 'collection', 'mdfDbTest', ...
                 'connect', 0);
            %
            % 
             
        end %function
    end %methods

    methods (Test)
        % 
        function testInstantiate(testCase)
            % 
            % just test instantiation of mdfDB
            obj = mdfDB.getInstance();
            % test that we got the correct object
            testCase.verifyClass(obj,'mdfDB');
            % delete singleton
            mdfDB.getInstance('release');
        end % function

        %
        function testConfiguration(testCase)
            %
            % instantiate the object and load the test configuration file
            obj = mdfDB.getInstance(testCase.configuration);
            % test that the configuration is a structure
            testCase.verifyClass(obj.host,'char');
            testCase.verifyClass(obj.port,'double');
            testCase.verifyClass(obj.database,'char');
            testCase.verifyClass(obj.collection,'char');
            % test that the db object has the test configuration 
            testCase.verifyEqual(obj.host,testCase.configuration.host);
            testCase.verifyEqual(obj.port,testCase.configuration.port);
            testCase.verifyEqual(obj.database,testCase.configuration.database);
            testCase.verifyEqual(obj.collection,testCase.configuration.collection);

            % delete singleton)
            mdfDB.getInstance('release');
        end % function

        %
        function testConnect(testCase)
            %
            % instantiate the object and load the configuration file
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % connect to container db object using index
            obj.connect();
            %
            % test that there is one container, that's what the test configuration says
            testCase.verifyClass(obj.db,'db');
            testCase.verifyClass(obj.db,'collection');
            %
            % test that the uuid is the same
            testCase.verifyEqual(obj.isValidConnection,true);

            % delete singleton)
            mdfDB.getInstance('release');
        end % function

        %
        function testInsert(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % insert one record
            res = obj.insert(testCase.records(1));
            % make sure that the insert returns 1
            testCase.verifyClass(res,1);
            
            % delete singleton
            mdfDB.getInstance('release');
        end % function

        %
        function testFind(testCase)
            %
            % test that we can find selected records

            %
            % insert record
            
            %
            % find record
            
            %
            % compare records
            
        end %function

        %
        function testUpdate(testCase)
            % test conf selection
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % insert record
            
            %
            % update record
            
            % find record
            
            % compare records

            % test that file has been loaded
            testCase.verifyEqual(obj.selection,1);
            % delete singleton)
            mdfDB.getInstance('release');
        end %function

        %
        function testDelete(testCase)
            % test instantiating the singleton with a struct and the full automation
            % instantiate class
            obj = mdfDB.getInstance(testCase.configuration);
            
            
            % check that the conf has been read
            testCase.verifyClass(obj.confData,'struct');
            % check that selection is correct
            testCase.verifyEqual(obj.selection,1);
            % check that we get the configuration back 
            testCase.verifyClass(obj.confData,'struct');


            % delete singleton
            mdfDB.getInstance('release');
        end %function

        %
        function testDeleteAll(testCase)
            % test universe
            obj = mdfDB.getInstance(testCase.configuration);
            %
            %
            % test that env is a struct
            testCase.verifyClass(uni,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                uni, ...
                obj.confData.universe.ecosystem{:});

            % delete singleton)
            mdfDB.getInstance('release');
  
        end %function

        %
        function testCollStats(testCase)
            % test ecosystem
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % load in all test records
            
            %
            % run coll stats
            
            %
            % check results
            testCase.verifyClass(eco,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                eco, ...
                obj.confData.universe.ecosystem{obj.selection});

            % delete singleton)
            mdfDB.getInstance('release');
        end %function

        %
        function testValidateRelationships(testCase)
            % test conf selection
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % load 
            env = obj.getEnv();
            %
            % test that env is a struct
            testCase.verifyClass(env,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                env, ...
                obj.confData.universe.ecosystem{obj.selection}.environment)

            % delete singleton)
            mdfDB.getInstance('release');
        end %function

        % 
        function testValidationUuid(testCase)
            % test habitats list
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % load test enviornment
            habs = obj.getHabitats();
            %
            % run validate uuid function
            testCase.verifyClass(habs,'cell');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                habs,  ...
                obj.confData.universe.ecosystem{obj.selection}.habitats.habitat)

            %
            % test get habitats by type
            h1 = habs;
            h1(~strcmp(cellfun(@(x) x.type, h1,'UniformOutput',0),'db')) = [];
            h2 = obj.getHabsByType('db');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                h1,  ...
                h2);

            % delete singleton)
            mdfDB.getInstance('release');
        end %function

        %
        function testValidationKeys(testCase)
            % test single habitat
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % load test environment
            
            %
            % request the full environemnt
            hab2 = obj.getHabitat(hab1.uuid);
            %
            % test that habitat is a struct
            testCase.verifyClass(hab2,'struct');
            %
            % test that uuid is correct
            testCase.verifyEqual(hab2.uuid,hab1.uuid);
            %
            % test that the habitat is the same
            testCase.verifyEqual(hab2,hab1);

            % delete singleton)
            mdfDB.getInstance('release');
        end %function
        
    end % methods
    
end % class
            
