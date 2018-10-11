classdef mdfObjConf3Test < mdfObjConfTest
    % 
    % unit tests for mdfObj
    %
    % creates an array of fake mdfObj for testing purposes
    %

    % properties
    properties
    end %properties

    methods
        function obj = mdfObjConf3Test()
            % calls super class constructor
            obj = obj@mdfObjConfTest();
            %
            % define properties
            obj.recordFolder = 'records/minimized';
            obj.testMdfType = 'TestObj';
            obj.testConfiguration = 3;
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
        
        function localTestSetFiles(testCase)
            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for this objects
            res = obj.setFiles(testCase.records{testCase.testRecordIndex}.mdf_def.mdf_files.mdf_base);
            %
            % check results
            testCase.verifyEqual( res.base, false );
            testCase.verifyEqual( res.metadata, false );
            testCase.verifyEqual( res.data, false );
            %
            %
            delete(obj);

            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for this objects
            res = obj.setFiles( ...
                struct( ...
                    'base', testCase.records{testCase.testRecordIndex}.mdf_def.mdf_files.mdf_base, ...
                    'metadata', testCase.records{testCase.testRecordIndex}.mdf_def.mdf_files.mdf_metadata, ...
                    'data', testCase.records{testCase.testRecordIndex}.mdf_def.mdf_files.mdf_data));
            %
            % check results
            testCase.verifyEqual( res.base, false );
            testCase.verifyEqual( res.metadata, false );
            testCase.verifyEqual( res.data, false );
            %
            %
            delete(obj);
        end % function

        %
        function localTestGetFiles(testCase)
            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for this object
            obj.mdf_def.mdf_files.mdf_base = ...
                testCase.records{testCase.testRecordIndex}.mdf_def.mdf_files.mdf_base;
            obj.mdf_def.mdf_files.mdf_data = ...
                testCase.records{testCase.testRecordIndex}.mdf_def.mdf_files.mdf_data;
            obj.mdf_def.mdf_files.mdf_metadata = ...
                testCase.records{testCase.testRecordIndex}.mdf_def.mdf_files.mdf_metadata;
            %
            % get files for this object
            res = obj.getFiles();
            %
            % check results
            testCase.verifyEqual( res.base, false);
            testCase.verifyEqual( res.metadata, false );
            testCase.verifyEqual( res.data, false);
            testCase.verifyEqual( ...
                obj.mdf_def.mdf_files.mdf_base, ...
                '');
            testCase.verifyEqual( ...
                obj.mdf_def.mdf_files.mdf_metadata, ...
                '');
            testCase.verifyEqual( ...
                obj.mdf_def.mdf_files.mdf_data, ...
                '');

            %
            % get files for this object
            res = obj.getFiles(false);
            %
            % check results
            testCase.verifyEqual( res.base, false );
            testCase.verifyEqual( res.metadata, false );
            testCase.verifyEqual( res.data, false);

            %
            %
            delete(obj);
            
        end %function

        %
        function localTestGetDFN(testCase)
            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for this object
            obj.mdf_def.mdf_files.mdf_data = ...
                testCase.records{testCase.testRecordIndex}.mdf_def.mdf_files.mdf_data;
            %
            % get files for this object
            res = obj.getDataFileName();
            %
            % check results
            testCase.verifyEqual( res, false );
            testCase.verifyEqual( ...
                obj.mdf_def.mdf_files.mdf_data, ...
                '');
            %
            % get files for this object
            res = obj.getDFN();
            %
            % check results
            testCase.verifyEqual( res, false );

            %
            % get files for this object
            res = obj.getDataFileName(false);
            %
            % check results
            testCase.verifyEqual( res, false );
            %
            % get files for this object
            res = obj.getDFN(false);
            %
            % check results
            testCase.verifyEqual( res, false );

            %
            %
            delete(obj);
            
        end %function

        %
        function localTestGetMFN(testCase)
            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for this object
            obj.mdf_def.mdf_files.mdf_metadata = ...
                testCase.records{testCase.testRecordIndex}.mdf_def.mdf_files.mdf_metadata;
            %
            % get files for this object
            res = obj.getMetadataFileName();
            %
            % check results
            testCase.verifyEqual( res, false );
            testCase.verifyEqual( ...
                obj.mdf_def.mdf_files.mdf_metadata, ...
                '');
            %
            % get files for this object
            res = obj.getMFN();
            %
            % check results
            testCase.verifyEqual( res, false );

            %
            % get files for this object
            res = obj.getMetadataFileName(false);
            %
            % check results
            testCase.verifyEqual( res, false );
            %
            % get files for this object
            res = obj.getMFN(false);
            %
            % check results
            testCase.verifyEqual( res, false );

            %
            %
            delete(obj);
            
        end %function

        %
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
            % nothing to do for database base data collections

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
                % remove object
                res = obj.remove();
                testCase.verifyEqual(res,true);
                % 
                % check that the dbentry is removed
                obj = mdfObj.load(testCase.uuids{i});
                testCase.verifyEmpty(obj);
            end %for

            % check that the number of objects in the database is correct
            stats = testCase.db.getCollStats();
            testCase.verifyEqual(length(stats),0);

        end % function

    end % methods
    
end % class
            
