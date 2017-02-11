classdef mdfObjPopulate < matlab.unittest.TestCase
    % 
    % unit tests for mdfConf
    %
    % load configuration file, extract and so on
    %

    % properties
    properties
        xmlConfFile = '';
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
        end %function
    end %methods

    methods (Test)
        % 
        function testInstantiate(testCase)
            % 
            % just test instantiation of mdfConf
            obj = mdfConf.getInstance(testCase.xmlConfFile);
            % test that we got the correct object
            testCase.verifyEqual(class(obj),'mdfConf');
            % delete singleton
            mdfConf.getInstance('release');
        end % function

        %
        function testLoad(testCase)
            %
            % instantiate the object and load the configuration file
            obj = mdfConf.getInstance(testCase.xmlConfFile;
            %
            obj.load();
            % test that file has been loaded
            % delete singleton
            mdfConf.getInstance('release');
        end % function
    end % methods
    
end % class
            
