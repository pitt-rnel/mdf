classdef mdfConfTest < matlab.unittest.TestCase
    % 
    % unit tests for mdfConf
    %
    % load configuration file, extract and so on
    %

    % properties
    properties
        xmlConfFile = '';
        testFolder = '';
        indata = struct();
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
            % set test configuration file, xml format
            testCase.xmlConfFile = fullfile(testCase.testFolder,'..', '..', '..', 'test', 'mdfConf','mdf_example_1.xml.conf');
            % 
            % set up input data to instantiate the object and have it ready for use
            testCase.indata = struct( ...
                'fileName', testCase.xmlConfFile, ...
                'automation', 'start', ...
                'menuType', 'text', ...
                'selection', [1 2]);

        end %function
    end %methods

    methods (Test)
        % 
        function testInstantiate(testCase)
            % 
            % just test instantiation of mdfConf
            obj = mdfConf.getInstance(testCase.xmlConfFile);
            % test that we got the correct object
            testCase.verifyClass(obj,'mdfConf');
            % delete singleton
            mdfConf.getInstance('release');
        end % function

        %
        function testLoad(testCase)
            %
            % instantiate the object and load the configuration file
            obj = mdfConf.getInstance(testCase.xmlConfFile);
            %
            obj.load();
            % test that file has been loaded
            testCase.verifyClass(obj.fileData,'org.apache.xerces.dom.DeferredDocumentImpl');
            % delete singleton)
            mdfConf.getInstance('release');
        end % function

        %
        function testExtraction(testCase)
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
        function testSelection(testCase)
            % test conf selection inall the different configurations
            % select which collection to connect right away
            obj = mdfConf.getInstance(testCase.xmlConfFile);
            %
            obj.load();
            obj.extract();
            %
            % set by struct
            obj.select( ...
                struct( ...
                	'collection', {obj.menu.collections.human_name}, ...
                    'selected', 0));
            % test if all of them has been unselected
            testCase.verifyEqual(obj.selection,logical([0 0]));
            %
            % select by index
            collId = 1;
            obj.select(collId);
            % test that file has been loaded
            testCase.verifyEqual(obj.selection(collId),true);
            %
            % select by machine name
            collId = 2;
            obj.select(obj.menu.collections(collId).machine_name);
            % test that file has been loaded
            testCase.verifyEqual(obj.selection(collId),true);
            
            % delete singleton)
            mdfConf.getInstance('release');
        end %function

        %
        function testAutomation(testCase)
            % test instantiating the singleton with a struct and the full automation
            % instantiate class
            obj = mdfConf.getInstance(testCase.indata);
            % check that the conf has been read
            testCase.verifyClass(obj.confData,'struct');
            % check that selection is correct
            testCase.verifyEqual(obj.selection,logical([1 1]));
            % check that we get the configuration back 
            testCase.verifyClass(obj.confData,'struct');

            % delete singleton
            mdfConf.getInstance('release');
        end %function

        %
        function testConfiguration(testCase)
            % test configuration
            obj = mdfConf.getInstance(testCase.indata);
            %
            % request the current full configuration structure
            conf = obj.getConf();
            %
            % test that env is a struct
            testCase.verifyClass(conf,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                conf, ...
                obj.confData);
            
            % decide which collection to use for testing
            collId = 1;
            %
            % request the current full configuration structure
            conf = obj.getConf(obj.menu.collections(collId).machine_name);
            %
            % test that env is a struct
            testCase.verifyClass(conf,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                conf, ...
                obj.confData.collections.collection{collId});
            
            %
            % request the current full configuration structure
            conf = obj.getConf(obj.menu.collections(collId).human_name);
            %
            % test that env is a struct
            testCase.verifyClass(conf,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                conf, ...
                obj.confData.collections.collection{collId});
            
            %
            % request the current full configuration structure
            conf = obj.getConf(collId);
            %
            % test that env is a struct
            testCase.verifyClass(conf,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                conf, ...
                obj.confData.collections.collection{collId});

            % delete singleton
            mdfConf.getInstance('release');
  
        end %function

        %
        function testVersion(testCase)
            % test configuration
            obj = mdfConf.getInstance(testCase.indata);
            %
            % request the current full confguration structure
            ver = obj.getVersion();
            %
            % test that env is a char
            testCase.verifyClass(ver,'char');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                ver, ...
                obj.confData.version);

            % delete singleton
            mdfConf.getInstance('release');

        end %function

        %
        function testCollections(testCase)
            % test all collections
            obj = mdfConf.getInstance(testCase.indata);
            %
            % request all collections
            colls = obj.getColls();
            %
            % test that env is a struct
            testCase.verifyClass(colls,'cell');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                colls, ...
                obj.confData.collections.collection);

        end %function

        %
        function testCollection(testCase)
            % test all collections
            obj = mdfConf.getInstance(testCase.indata);
            %
            % select the first collection in the test
            cid = 1;
            coll1 = obj.confData.collections.collection{cid};
            %
            % request collection 1
            coll2 = obj.getColl(cid);
            %
            % test that env is a struct
            testCase.verifyClass(coll2,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                coll2, ...
                coll1);
            %
            % request all collection by uuid
            coll2 = obj.getColl(coll1.uuid);
            %
            % test that env is a struct
            testCase.verifyClass(coll2,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                coll2, ...
                coll1);
            %
            % request all collection by uuid
            coll2 = obj.getColl(coll1.machine_name);
            %
            % test that env is a struct
            testCase.verifyClass(coll2,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                coll2, ...
                coll1);

        end %function

        %
        function testGlobalEnvironment(testCase)
            % test global environment
            obj = mdfConf.getInstance(testCase.indata);
            %
            % request global environment by default
            env= obj.getEnv();
            %
            % test that env is a struct
            testCase.verifyClass(env,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                env, ...
                obj.confData.environment);
            %
            % request global environment explicitly
            env = obj.getEnv('GLOBAL');
            %
            % test that env is a struct
            testCase.verifyClass(env,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                env, ...
                obj.confData.environment);

            % delete singleton)
            mdfConf.getInstance('release');
        end %function

        %
        function testEnvironment(testCase)
            % test conf selection
            obj = mdfConf.getInstance(testCase.indata);
            %
            % select the first collection in the test
            cid = 1;
            coll1 = obj.confData.collections.collection{cid};
            %
            % request the full environemnt
            env = obj.getEnv(cid);
            %
            % test that env is a struct
            testCase.verifyClass(env,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                env, ...
                coll1.environment)
            %
            % request the full environemnt
            env = obj.getEnv(coll1.uuid);
            %
            % test that env is a struct
            testCase.verifyClass(env,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                env, ...
                coll1.environment)
            %
            % request the full environemnt
            env = obj.getEnv(coll1.machine_name);
            %
            % test that env is a struct
            testCase.verifyClass(env,'struct');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                env, ...
                coll1.environment)


            % delete singleton)
            mdfConf.getInstance('release');
        end %function

        % 
        function testContainers(testCase)
            % test containers
            obj = mdfConf.getInstance(testCase.indata);
            %
            % request the full environemnt
            cont = obj.getConts();
            %
            % test that env is a struct
            testCase.verifyClass(cont,'cell');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                cont,  ...
                obj.confData.containers.container)


            % delete singleton)
            mdfConf.getInstance('release');
        end %function
        
        % 
        function testCollectionContainers(testCase)
            % test collection containers
            obj = mdfConf.getInstance(testCase.indata);
            %
            % select the first collection in the test
            cid = 1;
            coll1 = obj.confData.collections.collection{cid};
            %
            % request the containers of this collection
            cont = obj.getCollConts(cid);
            %
            % test that env is a struct
            testCase.verifyClass(cont,'cell');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                cont,  ...
                coll1.containers.container)
            %
            % request the containers of this collection
            cont = obj.getCollConts(coll1.uuid);
            %
            % test that env is a struct
            testCase.verifyClass(cont,'cell');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                cont,  ...
                coll1.containers.container)
            %
            % request the containers of this collection
            cont = obj.getCollConts(coll1.machine_name);
            %
            % test that env is a struct
            testCase.verifyClass(cont,'cell');
            %
            % test that some of the fields matches
            testCase.verifyEqual( ...
                cont,  ...
                coll1.containers.container)

            % delete singleton
            mdfConf.getInstance('release');
        end %function

        %
        function testCollectionContainer(testCase)
            % test single habitat
            obj = mdfConf.getInstance(testCase.indata);
            %
            % get uuid of the first habitat inthe configuration
            collid = 1;
            coll1 = obj.confData.collections.collection{collid};
            collcontid = 1;
            collcont1 = coll1.containers.container{collcontid};
            contid = obj.getContainerIndex(collcont1.uuid);
            cont1 = obj.confData.containers.container{contid};
            %
            % request the full environemnt
            cont2 = obj.getCollCont(coll1.uuid,cont1.uuid);
            %
            % test that habitat is a struct
            testCase.verifyClass(cont2,'struct');
            %
            % test that uuid is correct
            testCase.verifyEqual(cont2.uuid,cont1.uuid);
            %
            % test that the habitat is the same
            testCase.verifyEqual(cont2,cont1);
            %
            % request the full environemnt
            cont2 = obj.getCollCont(collid,contid);
            %
            % test that habitat is a struct
            testCase.verifyClass(cont2,'struct');
            %
            % test that uuid is correct
            testCase.verifyEqual(cont2.uuid,cont1.uuid);
            %
            % test that the habitat is the same
            testCase.verifyEqual(cont2,cont1);
            %
            % request the full environemnt
            cont2 = obj.getCollCont(coll1.machine_name,cont1.machine_name);
            %
            % test that habitat is a struct
            testCase.verifyClass(cont2,'struct');
            %
            % test that uuid is correct
            testCase.verifyEqual(cont2.uuid,cont1.uuid);
            %
            % test that the habitat is the same
            testCase.verifyEqual(cont2,cont1);

            % delete singleton)
            mdfConf.getInstance('release');
        end %function

        %
        function testConstants(testCase)
            % test single habitat
            obj = mdfConf.getInstance(testCase.indata);
            %
            % get uuid of the first habitat inthe configuration
            collid = 1;
            coll1 = obj.confData.collections.collection{collid};
            %
            % get environments
            envg = obj.confData.environment;
            env1 = coll1.environment;
            %
            % request global  constant implicitly
            c1 = obj.getConstant('TEST_BASE');
            %
            % test that habitat is a struct
            testCase.verifyEqual(envg.TEST_BASE,c1);
            %
            % request global constant explicitly
            c1 = obj.getConstant('GLOBAL','RAW_DATA_BASE');
            %
            % test that habitat is a struct
            testCase.verifyEqual(envg.RAW_DATA_BASE,c1);
            %
            % request constant of specific collection
            c2 = obj.getConstant(collid,'NAME');
            %
            % test that uuid is correct
            testCase.verifyEqual(env1.NAME,c2);
            %
            % request constant of specific collection
            c2 = obj.getConstant(coll1.uuid,'NAME');
            %
            % test that uuid is correct
            testCase.verifyEqual(env1.NAME,c2);
            %
            % request constant of specific collection
            c2 = obj.getConstant(coll1.machine_name,'NAME');
            %
            % test that uuid is correct
            testCase.verifyEqual(env1.NAME,c2);
            %
            % request constant of specific collection build on global one
            c3 = obj.getConstant(collid,'RAW_DATA_BASE');
            %
            % test that uuid is correct
            testCase.verifyEqual(env1.RAW_DATA_BASE,c3);


            % delete singleton)
            mdfConf.getInstance('release');
        end %function
        
    end % methods
    
end % class
            
