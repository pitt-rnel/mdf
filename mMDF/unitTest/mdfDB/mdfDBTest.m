classdef mdfDBTest < matlab.unittest.TestCase
    % 
    % unit tests for mdfDB
    %
    % load database class, instantiate connectors classes and test
    %

    % properties
    properties
        configuration = '';
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
            testCase.configuration = struct();
            testCase.configuration(1) = struct( ...
                 'human_name', 'mdf metadata test container 1', ...
                 'machine_name', 'metadata_test_container_1', ...
                 'connector', 'mongodb', ...
                 'type', 'mdf_metadata', ...
                 'uuid', 'cc73c702-c349-11e7-8b12-3f28f420e9cd', ...
                 'host' ,'localhost', ...
                 'port', '27017', ...
                 'database', 'mdf_test', ...
                 'collection', 'mdf_test_1', ...
                 'selected', 1 );
            testCase.configuration(2) = struct( ...
                 'human_name', 'mdf data test container 1', ...
                 'machine_name', 'data_test_container_1', ...
                 'connector', 'postgresql', ...
                 'type', 'mdf_data', ...
                 'uuid', 'cd0bf04a-c349-11e7-9f7e-c79901cff5dd', ...
                 'host', 'localhost', ...
                 'port', '27017', ...
                 'database', 'mdf_test', ...
                 'table', 'mdf_test_1');

        end %function
    end %methods

    methods (Test)
        % 
        function testInstantiate(testCase)
            % 
            % just test instantiation of mdfConf
            obj = mdfDB.getInstance( ...
                struct('containers',[]), ...
            );
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
            testCase.verifyClass(obj.configuration,'struct');
            % test that the db object has the test configuration 
            testCase.verifyEqual(obj.configuration,testCase.configuration);

            % delete singleton)
            mdfConf.getInstance('release');
        end % function

        %
        function testConnect(testCase)
            %
            % instantiate the object and load the configuration file
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % select first container in configuration
            contId = 1;
            cont = obj.configuration(contId);
            %
            % connect to container db object using index
            obj.connect(contId);
            %
            % test that there is one container, that's what the test configuration says
            testCase.verifyClass(length(obj.containers),1);
            %
            % test that the uuid is the same
            testCase.verifyEqual(cont.uuid,obj.containers(1).uuid);

            % delete singleton)
            mdfConf.getInstance('release');
        end % function

        %
        function testInit(testCase)
            %
            % instantiate the object and load the configuration file
            obj = mdfDB.getInstance(testCase.configuration);
            % init the object
            obj.init();
            % test that there is one container, that's what the test configuration says
            testCase.verifyClass(length(obj.containers),1);

            % delete singleton)
            mdfConf.getInstance('release');
        end % function

        %
        function testInsert(testCase)
            %
            % test conf extraction from string loaded
            obj = mdfConf.getInstance(testCase.xmlConfFile);
            %
            obj.load();
            obj.extract();
            % test that file has been loaded
            testCase.verifyClass(obj.confData,'struct');
            % delete singleton)
            mdfConf.getInstance('release');
        end % function

        %
        function testFind(testCase)
            %
            % test that we can find selected records

        end %function

        %
        function testUpdate(testCase)
            % test conf selection
            obj = mdfConf.getInstance(testCase.xmlConfFile);
            %
            obj.load();
            obj.extract();
            obj.select(1);
            % test that file has been loaded
            testCase.verifyEqual(obj.selection,1);
            % delete singleton)
            mdfConf.getInstance('release');
        end %function

        %
        function testDelete(testCase)
            % test instantiating the singleton with a struct and the full automation
            % instantiate class
            obj = mdfConf.getInstance(testCase.indata);
            % check that the conf has been read
            testCase.verifyClass(obj.confData,'struct');
            % check that selection is correct
            testCase.verifyEqual(obj.selection,1);
            % check that we get the configuration back 
            testCase.verifyClass(obj.confData,'struct');


            % delete singleton
            mdfConf.getInstance('release');
        end %function

        %
        function testUniverse(testCase)
            % test universe
            obj = mdfConf.getInstance(testCase.indata);
            %
            % request the current ecosystem
            uni = obj.getUniv();
            %
            % test that env is a struct
            testCase.verifyClass(uni,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                uni, ...
                obj.confData.universe.ecosystem{:});

            % delete singleton)
            mdfConf.getInstance('release');
  
        end %function

        %
        function testEcosystem(testCase)
            % test ecosystem
            obj = mdfConf.getInstance(testCase.indata);
            %
            % request the current ecosystem
            eco = obj.getEco();
            %
            % test that env is a struct
            testCase.verifyClass(eco,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                eco, ...
                obj.confData.universe.ecosystem{obj.selection});

            % delete singleton)
            mdfConf.getInstance('release');
        end %function

        %
        function testEnvironment(testCase)
            % test conf selection
            obj = mdfConf.getInstance(testCase.indata);
            %
            % request the full environemnt
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
            mdfConf.getInstance('release');
        end %function

        % 
        function testHabitats(testCase)
            % test habitats list
            obj = mdfConf.getInstance(testCase.indata);
            %
            % request the full environemnt
            habs = obj.getHabitats();
            %
            % test that env is a struct
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
            mdfConf.getInstance('release');
        end %function

        %
        function testHabitat(testCase)
            % test single habitat
            obj = mdfConf.getInstance(testCase.indata);
            %
            % get uuid of the first habitat inthe configuration
            hab1 = obj.confData.universe.ecosystem{obj.selection}.habitats.habitat{1};
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
            mdfConf.getInstance('release');
        end %function

        %
        function testConstant(testCase)
            % test single habitat
            obj = mdfConf.getInstance(testCase.indata);
            %
            % get uuid of the first habitat inthe configuration
            env1 = obj.confData.universe.ecosystem{obj.selection}.environment;
            %
            % request first constant
            c1 = obj.getConstant('DATA_BASE');
            %
            % test that habitat is a struct
            testCase.verifyEqual(env1.DATA_BASE,c1);
            %
            % request second constant
            c2 = obj.getConstant('CORE_BASE');
            %
            % test that uuid is correct
            testCase.verifyEqual(env1.CORE_BASE,c2);

            % delete singleton)
            mdfConf.getInstance('release');
        end %function
        
    end % methods
    
end % class
            
