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
            testCase.xmlConfFile = fullfile(testCase.testFolder,'..','conf','mdf.xml.conf');
            % 
            % set up input data to instantiate the object and have it ready for use
            testCase.indata = struct( ...
                'fileName', testCase.xmlConfFile, ...
                'automation', 'start', ...
                'menuType', 'text', ...
                'selection', 1);

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
        function testAutomation(testCase)
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
            
