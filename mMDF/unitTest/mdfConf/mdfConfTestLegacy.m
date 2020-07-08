classdef mdfConfTest < matlab.unittest.TestCase
    % 
    % unit tests for mdfConf
    %
    % load configuration file, extract and so on
    %

    % properties
    properties
        xmlConfFile = '';
        dcTypeValidationFile= '';
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
            testCase.xmlConfFile = fullfile(testCase.testFolder, '..', 'conf', 'mdf.xml.legacy.conf');
            %
            % set path to json file containing the info to validate data
            % collection type
            testCase.dcTypeValidationFile = fullfile(testCase.testFolder, '..', '..', '..', 'etc', 'dc_type_validation.json');
            % 
            % set up input data to instantiate the object and have it ready for use
            testCase.indata = struct( ...
                'fileName', testCase.xmlConfFile, ...
                'automation', 'start', ...
                'menuType', 'text', ...
                'selection', [1, 2, 3, 4, 5, 6, 7, 8, 10]);

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

            % get selection
            sel = obj.getSelectedConfiguration();
            % test if all of them has been unselected
            testCase.verifyEqual(sel,0);
            %
            % select all configuration and test
            for collId = [1:length(testCase.indata)]
                % select configuration
                obj.select(collId);
                % get selection
                [n, m, i] = obj.getSelectedConfiguration();
                % test that we have 1 collection selected
                testCase.verifyEqual(i,collId);
                % test that the collection selected is the right one
                testCase.verifyEqual(n,obj.confData.configurations.names{collId});
                testCase.verifyEqual(m,obj.confData.configurations.machines{collId});
            end %for
            
            % delete singleton)
            mdfConf.getInstance('release');
        end %function

        %
        function testAutomation(testCase)
            % test instantiating the singleton with a struct and the full automation
            
            for collId = [1:length(testCase.indata)]
                % instantiate class
                obj = mdfConf.getInstance(testCase.indata(collId));
                % check that the conf has been read
                testCase.verifyClass(obj.confData,'struct');
                % check that selection is correct
                [~, ~, i] = obj.getSelectedConfiguration();
                testCase.verifyEqual(i,testCase.indata(collId).selection);
                % delete singleton
                mdfConf.getInstance('release');
            end %for

        end %function

        %
        function testConfiguration(testCase)

            % instantiate conf object
            obj = mdfConf.getInstance(testCase.indata(1));

            for collId = [1:length(testCase.indata)]
                %
                % request the current full configuration structure
                conf = obj.getConfiguration(collId);
                %
                % test that env is a struct
                testCase.verifyClass(conf,'struct');
                %
                % test that some of the fields matches
                testCase.verifyEqual( ...
                    conf, ...
                    obj.confData.configurations.configuration{collId});
            
            end %for
            
            % delete singleton
            mdfConf.getInstance('release');
  
        end %function

        %
        function testCollectionConf1(testCase)
            
            for collId = [1, 2, 3]
                % test configuration
                obj = mdfConf.getInstance(testCase.indata(collId));
                %
                % getconfiguration selection
                collSel= testCase.indata(collId).selection;
                %
                % request the current full confguration structure
                collConf = obj.getCollectionConf();
                %
                % test that env is a char
                testCase.verifyClass(collConf,'struct');
                %
                % test that the collection conf isset properly
                testCase.verifyEqual( ...
                    collConf.METADATA, ...
                    'MONGODB');
                testCase.verifyEqual( ...
                    collConf.YAML, ...
                    true);
                testCase.verifyEqual( ...
                    collConf.DATA, ...
                    'MAT_FILES');
                %
                % get directly individual values
                mdConf = obj.getCollectionMetadata();
                testCase.verifyClass(mdConf,'char');
                testCase.verifyEqual( ...
                    yamlConf, ...
                    'MONGODB');
                
                yamlConf = obj.getCollectionYaml();
                testCase.verifyClass(yamlConf,'logical');
                testCase.verifyEqual( ...
                    yamlConf, ...
                    true);
                
                dataConf = obj.getCollectionData();
                testCase.verifyClass(dataConf,'char');
                testCase.verifyEqual( ...
                    dataConf, ...
                    'MAT_FILES');

                %
                % test new storage configuration
                storages = obj.getStorages();
                testCase.verifyClass(storages,'cell');
                testCase.verifyTrue(ismember('MONGODB',storages));
                testCase.verifyTrue(ismember('YAML_FILES',storages));
                testCase.verifyTrue(ismember('MAT_FILES',storages));

                % delete singleton
                mdfConf.getInstance('release');
            end %for

        end %function

        %
        function testCollectionConf2(testCase)
            
            for collId = [4, 5, 6]
                % test configuration
                obj = mdfConf.getInstance(testCase.indata(collId));
                %
                % getconfiguration selection
                collSel= testCase.indata(collId).selection;
                %
                % request the current full confguration structure
                collConf = obj.getCollectionConf();
                %
                % test that env is a char
                testCase.verifyClass(collConf,'struct');
                %
                % test that the collection conf isset properly
                testCase.verifyEqual( ...
                    collConf.METADATA, ...
                    'MONGODB');
                testCase.verifyEqual( ...
                    collConf.YAML, ...
                    false);
                testCase.verifyEqual( ...
                    collConf.DATA, ...
                    'MAT_FILES');
                %
                % get directly individual values
                mdConf = obj.getCollectionMetadata();
                testCase.verifyClass(mdConf,'char');
                testCase.verifyEqual( ...
                    yamlConf, ...
                    'MONGODB');
                
                yamlConf = obj.getCollectionYaml();
                testCase.verifyClass(yamlConf,'logical');
                testCase.verifyEqual( ...
                    yamlConf, ...
                    false);
                
                dataConf = obj.getCollectionData();
                testCase.verifyClass(dataConf,'char');
                testCase.verifyEqual( ...
                    dataConf, ...
                    'MAT_FILES');
                
                %
                % test new storage configuration
                storages = obj.getStorages();
                testCase.verifyClass(storages,'cell');
                testCase.verifyTrue(ismember('MONGODB',storages));
                testCase.verifyFalse(ismember('YAML_FILES',storages));
                testCase.verifyTrue(ismember('MAT_FILES',storages));

                % delete singleton
                mdfConf.getInstance('release');
            end %for

        end %function
        
        %
        function testCollectionConf3(testCase)
            
            for collId = [7, 8]
                % test configuration
                obj = mdfConf.getInstance(testCase.indata(collId));
                %
                % getconfiguration selection
                collSel= testCase.indata(collId).selection;
                %
                % request the current full confguration structure
                collConf = obj.getCollectionConf();
                %
                % test that env is a char
                testCase.verifyClass(collConf,'struct');
                %
                % test that the collection conf isset properly
                testCase.verifyEqual( ...
                    collConf.METADATA, ...
                    'MONGODB');
                testCase.verifyEqual( ...
                    collConf.YAML, ...
                    false);
                testCase.verifyEqual( ...
                    collConf.DATA, ...
                    'MONGODB_ALL');
                %
                % get directly individual values
                mdConf = obj.getCollectionMetadata();
                testCase.verifyClass(mdConf,'char');
                testCase.verifyEqual( ...
                    yamlConf, ...
                    'MONGODB');
                
                yamlConf = obj.getCollectionYaml();
                testCase.verifyClass(yamlConf,'logical');
                testCase.verifyEqual( ...
                    yamlConf, ...
                    false);
                
                dataConf = obj.getCollectionData();
                testCase.verifyClass(dataConf,'char');
                testCase.verifyEqual( ...
                    dataConf, ...
                    'MONGODB_ALL');
                %
                % test new storage configuration
                storages = obj.getStorages();
                testCase.verifyClass(storages,'cell');
                testCase.verifyFalse(ismember('YAML_FILES',storages));
                testCase.verifyTrue(ismember('MONGODB_ALL',storages));

                % delete singleton
                mdfConf.getInstance('release');
            end %for

        end %function

        %
        function testCollectionConf4(testCase)
            
            for collId = [10]
                % test configuration
                obj = mdfConf.getInstance(testCase.indata(collId));
                %
                % getconfiguration selection
                collSel= testCase.indata(collId).selection;
                %
                % request the current full confguration structure
                collConf = obj.getCollectionConf();
                %
                % test that env is a char
                testCase.verifyClass(collConf,'struct');
                %
                % test that the collection conf isset properly
                testCase.verifyEqual( ...
                    collConf.METADATA, ...
                    'MONGODB');
                testCase.verifyEqual( ...
                    collConf.YAML, ...
                    false);
                testCase.verifyEqual( ...
                    collConf.DATA, ...
                    'MONGODB_GRIDFS');
                %
                % get directly individual values
                mdConf = obj.getCollectionMetadata();
                testCase.verifyClass(mdConf,'char');
                testCase.verifyEqual( ...
                    yamlConf, ...
                    'MONGODB');
                
                yamlConf = obj.getCollectionYaml();
                testCase.verifyClass(yamlConf,'logical');
                testCase.verifyEqual( ...
                    yamlConf, ...
                    false);
                
                dataConf = obj.getCollectionData();
                testCase.verifyClass(dataConf,'char');
                testCase.verifyEqual( ...
                    dataConf, ...
                    'MONGODB_GRIDFS');
                
                                %
                % test new storage configuration
                storages = obj.getStorages();
                testCase.verifyClass(storages,'cell');
                testCase.verifyTrue(ismember('MONGODB',storages));
                testCase.verifyFalse(ismember('YAML_FILES',storages));
                testCase.verifyTrue(ismember('MONGODB_GRIDFS',storages));

                % delete singleton
                mdfConf.getInstance('release');
            end %for

        end %function
        
        %
        function testConstants(testCase)

            % test mixed collection
            obj = mdfConf.getInstance(testCase.indata(1));

            for collId = [1:length(testCase.indata)]
                %
                % getconfiguration selection
                collSel= testCase.indata(collId).selection;
                %
                % select configuration
                obj.select(collSel);
                %
                % get the complete configuration
                constants1 = obj.getConstants();
                %
                % get constants directly from struct
                constants2 = obj.confData.configurations.configuration{collId}.constants;
                %
                % test that constants are equal
                testCase.verifyEqual(constants1,constants2);
                
            end %for

            % delete singleton)
            mdfConf.getInstance('release');
        end %function
        
    end % methods
    
end % class
            
