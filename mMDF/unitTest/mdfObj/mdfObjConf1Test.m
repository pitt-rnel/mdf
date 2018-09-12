classdef mdfObjTest < matlab.unittest.TestCase
    % 
    % unit tests for mdfObj
    %
    % creates an array of fake mdfObj for testing purposes
    %

    % properties
    properties
        xmlConfFile = '';
        uuidsFile = '';
        testFolder = '';
        recordFolder = 'records/minimized';
        records = [];
        uuids = {};
        conf = [];
        db = [];
        manage = [];
        testObjIndex = 1;
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
            %testCase.testFolder = cpfp;
            % add path to core classes of mdf
            addpath(fullfile(cpfp,'..','..','core'));
            % add path to libs
            addpath(fullfile(cpfp,'..','..','libs','jsonlab'));
        end %function

        %
        function defineTestEnvironment(testCase)
            % prepare test environment
            %
            % set test configuration file, xml format
            testCase.xmlConfFile = fullfile(testCase.testFolder, '..', 'conf', 'mdf.xml.conf');
            testCase.uuidsFile = fullfile(testCase.testFolder, '..', 'conf', 'uuid.json');
            % 
            % set up input configuration to conf object
            testCase.confIndata = stestCase.testObjIndexuct( ...
                    'fileName', testCase.xmlConfFile, ...
                    'automation', 'start', ...
                    'menuType', 'text', ...
                    'selection', 1);

            %
            % set up mdf environment
            testCase.conf = mdfConf.getInstance(testCase.confIndata);
            %
            % set up input configuration to database object
            C = testCase.conf.getC();
            testCase.dbIndata = stestCase.testObjIndexuct( ...
                    'host', C.DB.HOST, ...
                    'port', C.DB.PORT, ...
                    'database', C.DB.DATABASE, ...
                    'collection', C.DB.COLLECTION, ...
                    'connect', testCase.testObjIndexue);
            testCase.db = mdfDb.getInstance(testCase.dbIndata);
            testCase.manage = mdfManage.getInstance();

            %
            % child property
            testCase.childProperty = 'test';
        end %function

        %
        function loadTestRecords(testCase)
            % prepare test values
            %
            % set test configuration
            testCase..recordFolder = ...
                fullfile( ...
                    testCase.testFolder, ...
                    testCase.recordFolder);

            %
            % list all the json files and extestCase.testObjIndexact just the names
            testCase.recordFiles = arrayfun( ...
                @(item)(fullfile(testCase.recordFolder,item.name)), ...
                dir(fullfile(testCase.recordFolder,'*.json')), ...
                'UniformOutput',0);
            
            % load all the records
            for i = [1:length(testCase.recordFiles)]
                jsonText = fileread(testCase.recordFiles{i});
                testCase.records{i} = jsondecode(jsonText);
            end %for

            % load uuids
            fid = fopen(testCase.uuidsFile,'r');
            jsonUuids = readlines(fid,inf);
            testCase.uuids = jsonencode(jsonUuids);

        end %function

        %
        function createTestUuids()
            for i = 1:10
                testCase.uuids{i} = char(java.util.UUID.randomUUID);
            end %for
        end %function

    end %methods

    methods (TestClassTeardown)
        function destestCase.testObjIndexoyMdfConf(testCase)
            mdfManage.getInstance('release');
            mdfDb.getInstance('release');
            mdfConf.getInstance('release');
            global omdfc;
            clear omdfc;
        end %function
    end %methods


    methods
        
        function res = populateMdfObjFromRecord(testCase,obj,record)
            % function res = testCase.populateMdfObjFromRecord(obj,record)
            %
            %
            % testCase.testObjIndexansfer fields from record to mdf obj
            obj.uuid = record.mdf_def.mdf_uuid;
            obj.type = record.mdf_def.mdf_type;
            obj.metadata = record.mdf_metadata;
            for i = 1:length(record.mdf_def.mdf_data.mdf_fields)
                dataField = record.mdf_def.mdf_data.mdf_fields[i];
                obj.data.(dataField) = record.(dataField);
            end %for
        end %function

        function uuid = getTestObjUuid(testCase)
            uuid = testCase.records{testCase.testObjIndex}.mdf_def.mdf_uuid);
        end %function



    end %methods

    methods (Test)
        % 
        function testInstantiate(testCase)
            % 
            % just test instantiation of mdfObj
            obj = mdfObj();
            % test that we got the correct object
            testCase.verifyClass(obj,'mdfObj');
            % delete object
            delete(obj);
        end % function

        %
        function testPopulate(testCase)
            %
            % test record used
            testCase.testObjIndex = 1;
            %
            % instantiate the object
            obj = mdfObj();
            % 
            % populate object
            testCase.populateMdfObjFromRecord( ...
                obj, ...
                testCase.records{testCase.testObjIndex});
            %
            % test that obj is populated correctly
            testCase.verifyEqual(obj.uuid,testCase.records{testCase.testObjIndex}.mdf_def.mdf_uuid);
            testCase.verifyEqual(obj.type,testCase.records{testCase.testObjIndex}.mdf_def.mdf_type);
            testCase.verifyEqual(obj.metadata,testCase.records{testCase.testObjIndex}.mdf_metadata);
            for i = 1:length(testCase.records{testCase.testObjIndex}.mdf_def.mdf_data.mdf_fields)
                dataProp = testCase.records{testCase.testObjIndex}.mdf_def.mdf_data.mdf_fields{i};
                testCase.verifyEqual( ...
                    obj.data.(dataProp), ...
                    testCase.records{testCase.testObjIndex}.(dataProp));
            end %for
            % delete obj
            delete(obj);
        end % function

        %
        function testSetFiles(testCase)
            %
            % test record used
            testCase.testObjIndex = 1;
            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for thisobjects
            res = obj.setFiles(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base);
            %
            % check results
            testCase.verifyEqual( ...
                res.base, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base));
            testCase.verifyEqual( ...
                res.metadata, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            testCase.verifyEqual( ...
                res.data, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
            %
            %
            delete(obj);

            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for thisobjects
            res = obj.setFiles( ...
                stestCase.testObjIndexuct( ...
                    'base', testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base, ...
                    'metadata', testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata, ...
                    'data', testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
            %
            % check results
            testCase.verifyEqual( ...
                res.base, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base));
            testCase.verifyEqual( ...
                res.metadata, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            testCase.verifyEqual( ...
                res.data, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
            %
            %
            delete(obj);
        end % function

        %
        function testGetFiles(testCase)
            %
            % test record used
            testCase.testObjIndex = 1;
            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for this object
            res = obj.setFiles(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base);
            %
            % get files for this object
            res = obj.getFiles();
            %
            % check results
            testCase.verifyEqual( ...
                res.base, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base));
            testCase.verifyEqual( ...
                res.metadata, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            testCase.verifyEqual( ...
                res.data, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));

            %
            % get files for this object
            res = obj.getFiles(false);
            %
            % check results
            testCase.verifyEqual( ...
                res.base, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base);
            testCase.verifyEqual( ...
                res.metadata, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata);
            testCase.verifyEqual( ...
                res.data, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data);

            %
            %
            delete(obj);
            
        end %function

        %
        function testGetDFN(testCase)
            %
            % test record used
            testCase.testObjIndex = 1;
            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for this object
            res = obj.setFiles(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base);
            %
            % get files for this object
            res = obj.getDataFileName();
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
            %
            % get files for this object
            res = obj.getDFN();
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));

            %
            % get files for this object
            res = obj.getDataFileName(false);
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data);
            %
            % get files for this object
            res = obj.getDFN(false);
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data);

            %
            %
            delete(obj);
            
        end %function


        %
        function testGetMFN(testCase)
            %
            % test record used
            testCase.testObjIndex = 1;
            %
            % instantiate the object
            obj = mdfObj();
            %
            % set files for this object
            res = obj.setFiles(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base);
            %
            % get files for this object
            res = obj.getMetadataFileName();
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            %
            % get files for this object
            res = obj.getMFN();
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.conf.filter(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));

            %
            % get files for this object
            res = obj.getMetadataFileName(false);
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata);
            %
            % get files for this object
            res = obj.getMFN(false);
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata);

            %
            %
            delete(obj);
            
        end %function

        %
        function testSaveObjects(testCase)
            % 
            % create mdf objects and save them to db
            for i = 1:length(testCase.records)

                %
                % instantiate the object
                obj = mdfObj();
                %
                % populate object
                testCase.populateMdfObjFromRecord( ...
                    obj, ...
                    testCase.records{j});

                %
                % set files for this object
                res = obj.setFiles(testCase.records{j}.mdf_def.mdf_files.mdf_base);

                %
                % save object
                res = obj.save();
 
                %
                verifyEqual(res,testCase.testObjIndexue);
            end %for

            % check that the number of objects in the database is correct
            stats = testCase.db.getCollStat();
            verifyEqual(length(stats),1);
            verifyEqual(stats.mdfType,'TestObj');
            verifyEqual(stats.count,2);

            % check that we have files for the 2 objects in the data folder
            for i = 1:length(testCase.records)
                res = exist( ...
                    testCase.conf.filter(testCase.records{i}.mdf_def.mdf_files.mdf_metadata), ...
                    'file');
                verifyEqual(res,2);
                res = exist( ...
                    testCase.conf.filter(testCase.records{i}.mdf_def.mdf_files.mdf_data), ...
                    'file');
                verifyEqual(res,2);
            end % for

            %
            %
            omdfc.manage.clearAll(); 
        end % function

        %
        function testLoadFileInfo(testCase)
            %
            % test loadFileInfo on yml and mat file
            %
            % records we work with
            testCase.testObjIndex = 1;
            %
            % 
            res = mdfObj.fileLoadInfo( ...
                    testCase.conf.filter( ...
                        testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            verifyEqual( ...
                res.mdf_def.mdf_uuid, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_uuid));
            verifyEqual( ...
                res.mdf_def.mdf_type, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_type));
            verifyEqual( ...
                res.mdf_metadata, ...
                testCase.records{testCase.testObjIndex}.mdf_metadata));
            %    
            %
            res = mdfObj.fileLoadInfo( ...
                    omdfc.conf.filter( ...
                        testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
            verifyEqual( ...
                res.mdf_def.mdf_uuid, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_uuid));
            verifyEqual( ...
                res.mdf_def.mdf_type, ...
                testCase.records{testCase.testObjIndex}.mdf_def.mdf_type));
            verifyEqual( ...
                res.mdf_metadata, ...
                testCase.records{testCase.testObjIndex}.mdf_metadata));

        end %function

        %
        function testLoadByUuid(testCase)
            % 
            % load the 2 objects individually by uuid
            for i = 1:length(testCase.records)
                % load by uuid
                obj = mdfObj.load(testCase.records{i}.mdf_def.mdf_uuid);
                %
                verifyClass(obj,mdfObj);
              
                %
                % test that obj is populated correctly
                testCase.verifyEqual(obj.uuid,testCase.records{testCase.testObjIndex}.mdf_def.mdf_uuid);
                testCase.verifyEqual(obj.type,testCase.records{testCase.testObjIndex}.mdf_def.mdf_type);
                testCase.verifyEqual(obj.metadata,testCase.records{testCase.testObjIndex}.mdf_metadata);
            end % for
            %
            % remove objects from memory
            testCase.manage.clearAll();
        end % function

        %
        function testLoadAll(testCase)
            % 
            % load the all objects individually by type
            objs = mdf.load('mdf_type','TestObj');
            %
            verifyEqual(length(objs),2);
            %
            for i = 1:length(testCase.results)
                %
                % test that obj is populated correctly
                testCase.verifyEqual(obj.uuid,testCase.records{i}.mdf_def.mdf_uuid);
                testCase.verifyEqual(obj.type,testCase.records{i}.mdf_def.mdf_type);
                testCase.verifyEqual(obj.metadata,testCase.records{i}.mdf_metadata);
            end % for
            %
            % remove objects from memory
            testCase.manage.clearAll();
        end % function

        %
        function testLoadByFile(testCase)
            %
            % test record used
            testCase.testObjIndex = 1;
            % 
            % load one object using the yaml file
            obj = mdf.load( ...
                 omdfc.conf.filter( ...
                     testCase.record{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            %
            %
            testCase.verifyClass(obj,'mdfObj');
            testCase.verifyEqual(obj.uuid,testCase.records{testCase.testObjIndex}.mdf_def.mdf_uuid);
            testCase.verifyEqual(obj.type,testCase.records{testCase.testObjIndex}.mdf_def.mdf_type);
            testCase.verifyEqual(obj.metadata,testCase.records{testCase.testObjIndex}.mdf_metadata);
            %
            % remove objects from memory
            testCase.manage.clearAll();

            % 
            % load one object using the mat data file
            obj = mdf.load( ...
                 omdfc.conf.filter( ...
                     testCase.record{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
            %
            %
            testCase.verifyClass(obj,'mdfObj');
            testCase.verifyEqual(obj.uuid,testCase.records{testCase.testObjIndex}.mdf_def.mdf_uuid);
            testCase.verifyEqual(obj.type,testCase.records{testCase.testObjIndex}.mdf_def.mdf_type);
            testCase.verifyEqual(obj.metadata,testCase.records{testCase.testObjIndex}.mdf_metadata);
            %
            % remove objects from memory
            testCase.manage.clearAll();

        end % function

        %
        function testDataLoad(testCase)
            %
            % this function test the functionthat is responsible for lazy loading 
            % data properties
            %
            % load mdf object 
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % load inidividually the data properties
            for i = 1:length(testCase.records{testCase.testObjIndex}.mdf_def.mdf_data.mdf_fields)
                dataProp = testCase.records{testCase.testObjIndex}.mdf_def.mdf_data.mdf_fields{i};
                res = obj.dataLoad(dataProp);
                testCase.verifyEqual( res, 1);
            end %for

            res = obj.dataLoad('prop_not_exist');
            testCase.verifyEqual( res, 0);
     
            % remove objects from memory
            testCase.manage.clearAll();
        end %function

        %
        function testGetData(testCase)
            %
            % this function test the dataLoad function
            % 
            % load the 2 objects individually by uuid and load data properties
            for i = 1:length(testCase.records)
                % load by uuid
                obj = mdfObj.load(testCase.records{i}.mdf_def.mdf_uuid);
              
                %
                % test that obj is populated correctly
                for i = 1:length(testCase.records{testCase.testObjIndex}.mdf_def.mdf_data.mdf_fields)
                    dataProp = testCase.records{testCase.testObjIndex}.mdf_def.mdf_data.mdf_fields{i};
                    testCase.verifyEqual( ...
                        obj.data.(dataProp), ...
                        testCase.records{testCase.testObjIndex}.(dataProp));
                end %for
            end % for
            %
            % remove objects from memory
            testCase.manage.clearAll();
        end % function

        %
        function testUnload(testCase)
            %
            % load  one of the test objects
            obj = mdfObj.load(testCase.getTestObjUuid());
            % 
            % unload object
            res = mdfObj.unload(obj);
            
            testCase.verifyEqual(res,1);
            %
            % remove objects from memory
            testCase.manage.clearAll();

        end %function

        function testListDataProperties(testCase)
            %
            % load  one of the test objects
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get lis of data properties
            ldp = obj.getListDataProperties();
            %
            testCase.verifyEqual( ...
                ldp, ...
                testCase.records(testCase.testObjIndex).mdf_def.mdf_data.mdf_fields);
            
            %
            % get lis of data properties
            ldp = obj.getLDP();
            %
            testCase.verifyEqual( ...
                ldp, ...
                testCase.records(testCase.testObjIndex).mdf_def.mdf_data.mdf_fields);
            %
            % remove objects from memory
            testCase.manage.clearAll();
            
        end % function

        %
        function testAddChildren(testCase)
            %
            % test addChild functionality
            %
            % load object 
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % add children
            res = testCase.testObjIndexue;
            for i = 1:length(testCase.uuids)
                res1 = obj.addChild(testCase.testProperty,testCase.uuids{i});
                res = res & res1;
            end
            testCase.verifyEqual(res,testCase.testObjIndexue);
            testCase.verifyEqual( ...
                testCase.testProperty, ...
                obj.mdf_def.mdf_children.mdf_fields{0});
            testCase.verifyEqual( ...
                length(testCase.uuids), ...
                length(obj.mdf_def.mdf_children.(testCase.testProperty)));

            %
            % clear memory
            testCase.manage.clearAll();

            % 
            % randomize the insert order and select a position
            order = randperm(length(testCase.uuids));
            pos = order(1);

            %
            % add all children excepct last
            for i = 1:length(testCase.uuids)-1
                res = obj.addChild( ...
                    testCase.testProperty, ...
                    testCase.uuids{i}, ...
                    );
            end
            % add last child in predefind position
            res = obj.addChild( ...
                testCase.testProperty,
                testCase.uuids{end},
                pos);
            testCase.verifyEqual(res,testCase.testObjIndexue);
            testCase.verifyEqual( ...
                length(testCase.uuids), ...
                length(obj.mdf_def.mdf_children.(testCase.testProperty)));
            testCase.verifyEqual( ...
                testCase.uuids{end}, ...
                obj.mdf_def.mdf_children.(testCase.testProperty)(pos));

            % this time save the object
            res = obj.save()
            testCase.verifyEqual(res,testCase.testObjIndexue);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetChildrenIter(testCase)
            %
            % test for function getPropIter
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid);
            %
            % get vector iterator
            iter = obj.getPropIter(...
                testCase.testProperty, ...
                'asc', ...
                'children');
            % 
            % verify that we got the right thing
            testCase.verifyEqual(iter,[1:length(obj.mdf_def.mdf_children.(testCase.testProperty))]);

            %
            % get vector iterator
            iter = obj.getPropIter(...
                testCase.testProperty, ...
                'desc', ...
                'children');
            % 
            % verify that we got the right thing
            testCase.verifyEqual(iter,[length(obj.mdf_def.mdf_children.(testCase.testProperty)):-1:1]);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetChildrenUuids(testCase)
        end % function

        %
        function testGetChildren(testCase)
        end % function

        %
        function testGetChildrenLen(testCase)
        end % function

        %
        function testIsChildrenProp(testCase)
        end % function

        %
        function testRmChildren(testCase)
        end % function


        %
        function testClone(testCase)
        end % function

        %
        function testGetSize(testCase)
        end % function


    end % methods
    
end % class
            
