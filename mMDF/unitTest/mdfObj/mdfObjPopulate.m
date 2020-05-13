classdef mdfObjPopulate < matlab.unittest.TestCase
    % 
    % unit tests for mdfObj populate function
    %
    % database and files needs to be created and in place

    % properties
    properties
        testFolder = '';
        dataFolder = '';
        timestamp = '';
        objJson1 = '';
        objStruct1 = [];
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
            % time stamp as of now
            testCase.timestamp = datestr(now','yyyy-mm-dd HH:MM:SS');
            %
            % test files folder
            testCase.dataFolder = fullfile(testCase.testFolder,'..','data'); 
            % 
            % 
            testCase.objJson1 = ['{ ' ...
             '"mdf_version": 1, ' ...
             '"mdf_def": { ' ...
              '"mdf_type": "mMdfTest", ' ...
              '"mdf_uuid": "643da923-4250-4859-bb4a-5c0b150d1bea", ' ...
              '"mdf_vuuid": "11110313-d364-46af-ac62-c47f006e164e", ' ...
              '"mdf_created": "' testCase.timestamp '", ' ...
              '"mdf_modified": "' testCase.timestamp '", ' ...
              '"mdf_files": {' ...
               '"mdf_base": "' fullfile(testCase.dataFolder, 'unittest') '", ' ...
               '"mdf_data": "' fullfile(testCase.dataFolder, 'unittest.d.mat') '", ' ...
               '"mdf_metadata": "' fullfile(testCase.dataFolder, 'unittest.md.yml') '" ' ...
              '}, ' ...
              '"mdf_data": { ' ...
               '"mdf_fields": [ "waveform" ], ' ...
               '"waveform": {' ...
                '"mdf_class": "double", ' ...
                '"mdf_size": [ 1000, 1 ], ' ...
                '"mdf_mem": 100000 ' ...
               '} ' ...
              '}, ' ...
              '"mdf_metadata": { },  ' ...
              '"mdf_children" : { ' ... 
               '"mdf_fields" : [ ], ' ...
               '"mdf_types" : [ ] ' ...
              '}, ' ...
              '"mdf_parents" : {  }, ' ...
              '"mdf_links" : { ' ...
               '"mdf_fields" : [ ], ' ...
               '"mdf_types" : [ ], ' ...
               '"mdf_directions" : [ ] ' ...
              '} ' ...
             '}, ' ...
             '"mdf_metadata": { ' ...
              '"subject" : "mdfObjUnitTest", ' ...
              '"type" : "waveform", ' ...
              '"experiment" : "unknown" ' ...
             '} ' ...
            '}'];
            % convert json to matlab struct
            testCase.objStruct1 = loadjson(testCase.objJson1);
        end %function
    end %methods

%     methods(TestMethodSetup)
%         function setup(testCase)
%             % comment
%             testCase.TestFigure = figure;
%         end % function
%     end %methods
%  
%     methods(TestMethodTeardown)
%         function closeFigure(testCase)
%             close(testCase.TestFigure)
%         end
%     end
%     
    methods (Test)
        % 
        function testPopulateFromStruct(testCase)
            % test to populate object from struct
            obj = mdfObj();
            obj.populate(testCase.objStruct1);
            % test uuid
            testCase.verifyEqual(obj.uuid,testCase.objStruct.mdf_def.mdf_uuid);
            % test type
            testCase.verifyEqual(obj.type,testCase.objStruct.mdf_def.mdf_type);
            % test metadata
            testCase.verifyEqual(obj.metadata.subject,testCase.objStruct.mdf_metadata.subject);
            testCase.verifyEqual(obj.metadata.type,testCase.objStruct.mdf_metadata.type);
            testCase.verifyEqual(obj.metadata.experiment,testCase.objStruct.mdf_metadata.experiment);
        end % function
        %
        function testPopulateFromJson(testCase)
            % test to populate object from struct
            obj = mdfObj();
            obj.populate(testCase.objJson1);
            % test uuid
            testCase.verifyEqual(obj.uuid,testCase.objStruct.mdf_def.mdf_uuid);
            % test type
            testCase.verifyEqual(obj.type,testCase.objStruct.mdf_def.mdf_type);
            % test metadata
            testCase.verifyEqual(obj.metadata.subject,testCase.objStruct.mdf_metadata.subject);
            testCase.verifyEqual(obj.metadata.type,testCase.objStruct.mdf_metadata.type);
            testCase.verifyEqual(obj.metadata.experiment,testCase.objStruct.mdf_metadata.experiment);
        end % function
    end % methods
    
end % class
            