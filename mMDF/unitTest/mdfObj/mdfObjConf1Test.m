classdef mdfObjConf1Test < mdfObjConfTest
    % 
    % unit tests for mdfObj
    %
    % creates an array of fake mdfObj for testing purposes
    %

    % properties
    properties
    end %properties

    methods
        function obj = mdfObjConf1Test()
            % calls super class constructor
            obj = obj@mdfObjConfTest();
            %
            % define properties
            obj.recordFolder = 'records/minimized';
            obj.testMdfType = 'TestObj';
            obj.testConfiguration = 1;
        end %function
    end %methods
    
    methods (TestClassSetup)

        %
        function defineTestEnvironment(testCase)
            % prepare test environment
            %
            % set test configuration file, xml format
            testCase.xmlConfFile = fullfile(testCase.testFolder, '..', 'conf', 'mdf.xml.conf');
            testCase.uuidsFile = fullfile(testCase.testFolder, '..', 'conf', 'uuids.json');
            
            defineTestEnvironment@mdfObjConfTest(testCase);

        end %function

    end %methods

    methods (TestClassTeardown)
    end %methods


    methods
        
        function localTestSaveObjects(testCase)
            % 
            % create mdf objects and save them to db
            for i = 1:length(testCase.uuids)

                %
                % create test object
                obj = testCase.createMdfObjFromUuid( ...
                    testCase.uuids{i});

                %
                % save object
                res = obj.save();
 
                %
                testCase.verifyEqual(res,true);
                res = exist( ...
                    obj.getMFN(), ...
                    'file');
                testCase.verifyEqual(res,2);
                res = exist( ...
                    obj.getDFN(), ...
                    'file');
                testCase.verifyEqual(res,2);
            end % for

            % check that the number of objects in the database is correct
            stats = testCase.db.getCollStats();
            testCase.verifyEqual(length(stats),1);
            testCase.verifyEqual(stats.mdf_type,'TestObj');
            testCase.verifyEqual(stats.value,length(testCase.uuids));

        end % function

        %
        function localTestLoadFileInfo(testCase)
            %
            % test loadFileInfo on yml and mat file
            % 
            mdfData = mdfObj.fileLoadInfo( ...
                    testCase.conf.filter( ...
                        testCase.getFilenameFromUuid( ...
                            testCase.uuids{testCase.testObjIndex},'data')));
            testCase.verifyEqual( ...
                mdfData.mdf_def.mdf_uuid, ...
                testCase.uuids{testCase.testObjIndex});
            testCase.verifyEqual( ...
                mdfData.mdf_def.mdf_type, ...
                testCase.testMdfType);
            testCase.verifyEqual( ...
                mdfData.mdf_metadata.name, ...
                [ testCase.testMdfType ' ' testCase.uuids{testCase.testObjIndex}]);
            %    
            %
            mdfData = mdfObj.fileLoadInfo( ...
                    testCase.conf.filter( ...
                        testCase.getFilenameFromUuid( ...
                            testCase.uuids{testCase.testObjIndex},'metadata')));
            testCase.verifyEqual( ...
                mdfData.mdf_def.mdf_uuid, ...
                testCase.uuids{testCase.testObjIndex});
            testCase.verifyEqual( ...
                mdfData.mdf_def.mdf_type, ...
                testCase.testMdfType);
            testCase.verifyEqual( ...
                mdfData.mdf_metadata.name, ...
                [ testCase.testMdfType ' ' testCase.uuids{testCase.testObjIndex}]);

        end %function

        %
        function localTestDeleteObjects(testCase)
            %
            % remove (aka delete) objects from this data collection
            %
            % load all objects and remove them
            for i = 1:length(testCase.uuids)
                %
                % load object
                obj = mdfObj.load(testCase.uuids{i});
                %
                % get file name
                dFile = obj.getDFN();
                mFile = obj.getMFN();
                %
                % remove object
                obj.remove();
                % 
                % check that the dbentry is removed
                obj = mdfObj.load(testCase.uuids{i});
                testCase.verifyEmpty(obj);
                %
                % verify that the files is gone
                res = exist( dFile, 'file');
                testCase.verifyEqual(res,0);
                res = exist( mFile, 'file');
                testCase.verifyEqual(res,0);
            end %for

        end % function


    end % methods
    
end % class
            
