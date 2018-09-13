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
        testMdfType = 'TestObj';
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
        %function createTestUuids()
        %    for i = 1:10
        %        testCase.uuids{i} = char(java.util.UUID.randomUUID);
        %    end %for
        %end %function

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

        function filename = getFilenameFromUuid(uuid,type)
            switch lower(type)
                case 'data'
                    filename = fullfile( '<DATA_BASE>', [testCase.testMdfType '_' uuid '.md.yml'] );
                case 'name'
                    filename = fullfile( '<DATA_BASE>', [testCase.testMdfType '_' uuid '.d.mat'] );
                otherwise
                    filename = fullfile( '<DATA_BASE>', [testCase.testMdfType '_' uuid] );
            end %switch
        end %function

        function obj = createMdfObjFromUuid(uuid)
            %
            % instantiate the object
            obj = mdfObj(uuid,testCase.testMdfType);
            %
            % set files for this object
            res = obj.setFiles( testCase.getFilenameFromUuid(uuid));
            %
            % add some metadata
            obj.metadata.name = [testCase.testMdfType ' ' uuid];
            %
            % add data properties
            obj.data.time = [1:100];
            obj.data.signal = awgn(sin(obj.data.time),10,'measured');         

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
            % instantiate the object
            obj = mdfObj();
            %
            % set files for thisobjects
            res = obj.setFiles(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base);
            %
            % check results
            testCase.verifyEqual( ...
                res.base, ...
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base));
            testCase.verifyEqual( ...
                res.metadata, ...
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            testCase.verifyEqual( ...
                res.data, ...
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
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
                testCase.conf.filter( ..
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base));
            testCase.verifyEqual( ...
                res.metadata, ...
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            testCase.verifyEqual( ...
                res.data, ...
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
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
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base));
            testCase.verifyEqual( ...
                res.metadata, ...
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            testCase.verifyEqual( ...
                res.data, ...
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));

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
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
            %
            % get files for this object
            res = obj.getDFN();
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));

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
                testCase.conf.filter(
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));
            %
            % get files for this object
            res = obj.getMFN();
            %
            % check results
            testCase.verifyEqual( ...
                res, ...
                testCase.conf.filter( ...
                    testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata));

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
            for i = 1:length(testCase.uuids)

                %
                % create test object
                obj = testCase.createMdfObjFromUuid( ...
                    testCase.uuids{j});

                %
                % save object
                res = obj.save();
 
                %
                verifyEqual(res,true);
                res = exist( ...
                    obj.getMFN(), ...
                    'file');
                verifyEqual(res,2);
                res = exist( ...
                    obj.getDFN(), ...
                    'file');
                verifyEqual(res,2);
            end % for

            % check that the number of objects in the database is correct
            stats = testCase.db.getCollStat();
            verifyEqual(length(stats),1);
            verifyEqual(stats.mdfType,'TestObj');
            verifyEqual(stats.count,2);

            %
            %
            omdfc.manage.clearAll(); 
        end % function

        %
        function testLoadFileInfo(testCase)
            %
            % test loadFileInfo on yml and mat file
            % 
            res = mdfObj.fileLoadInfo( ...
                    testCase.conf.filter( ...
                        testCase.getFilenameFromUuid( ...
                            testCase.uuids{testCase.testObjIndex},'data')));
            verifyEqual( ...
                res.mdf_def.mdf_uuid, ...
                testCase.uuids{testCase.testObjIndex});
            verifyEqual( ...
                res.mdf_def.mdf_type, ...
                testCase.testMdfType);
            verifyEqual( ...
                res.mdf_metadata.name, ...
                [ testCase.testMdfType ' ' testCase.uuids{testCase.testObjIndex}]);
            %    
            %
            res = mdfObj.fileLoadInfo( ...
                    testCase.conf.filter( ...
                        testCase.getFilenameFromUuid( ...
                            testCase.uuids{testCase.testObjIndex},'metadata')));
            verifyEqual( ...
                res.mdf_def.mdf_uuid, ...
                testCase.uuids{testCase.testObjIndex});
            verifyEqual( ...
                res.mdf_def.mdf_type, ...
                testCase.testMdfType);
            verifyEqual( ...
                res.mdf_metadata.name, ...
                [ testCase.testMdfType ' ' testCase.uuids{testCase.testObjIndex}]);

        end %function

        %
        function testLoadByUuid(testCase)
            % 
            % load the 2 objects individually by uuid
            for i = 1:length(testCase.uuids)
                % load by uuid
                obj = mdfObj.load(testCase.uuids{i});
                %
                verifyClass(obj,mdfObj);
              
                %
                % test that obj is populated correctly
                testCase.verifyEqual( ...
                    obj.uuid, ...
                    testCase.uuid{i});
                testCase.verifyEqual( ...
                    obj.type, ...
                    testCase.testMdfType);
                testCase.verifyEqual( ...
                    obj.metadata.name, ...
                    [ testCase.testMdfType ' ' testCase.uuids{testCase.testObjIndex}]);
            end % for
            %
            % remove objects from memory
            testCase.manage.clearAll();
        end % function

        %
        function testLoadAll(testCase)
            % 
            % load the all objects individually by type
            objs = mdf.load('mdf_type',testCase.testMdfType);
            %
            verifyEqual(length(objs),length(testCase.uuids));
            %
            for i = 1:length(testCase.uuids)
                %
                % test that obj is populated correctly
                testCase.verifyEqual( ...
                    objs(i).uuid, ...
                    testCase.uuids{i});
                testCase.verifyEqual( ...
                    objs(i).type, ...
                    testCase.testMdfType);
                testCase.verifyEqual( ...
                    objs(i).metadata.name, ...
                    [ testCase.testMdfType ' ' testCase.uuids{testCase.testObjIndex}]);
            end % for

            %
            %
            omdfc.manage.clearAll(); 
        end % function

        %
        function testDataLoad(testCase)
            %
            % this function test the functionthat is responsible for lazy loading 
            % data properties
            %
            % load mdf object 
            obj = mdfObj.load(testCase.uuids{testCase.testObjIndex});
            %
            % load inidividually the data properties
            dataProperties = obj.getLDP();
            for i = 1:length(dataProperties)
                dataProp = dataProperties{i};
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
            for i = 1:length(testCase.uuids)
                % load by uuid
                obj = mdfObj.load(testCase.uuids{i});
              
                %
                % test that obj is populated correctly
                dataProperties = obj.getLDP();
                for i = 1:length(dataProperties)
                    dataProp = dataProperties{i};
                    test = obj.data.(dataProp);
                    %
                    testCase.verifyEqual(obj.status.loaded.data.(dataProp), true);
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
            obj = mdfObj.load(testCase.uuids(testCase.testObjIndex));
            % 
            % unload object
            res = mdfObj.unload(obj);
            testCase.verifyEqual(res,1);

            %
            % remove objects from memory
            testCase.manage.clearAll();

        end %function
%--------
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
            res = true;
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
            testCase.verifyEqual(res,true);

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
            %
            % test for function getUuids
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid);
            %
            % get uuids of the children
            uuids = obj.getUuids('children',testCase.testProperty,'default');
            %
            % check if the uuids are the same that we inserted
            testCase.verifyEqual(sort(uuids),sort(testCase.uuids));

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetChildrenLen(testCase)
            %
            % test for function getLen
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid);
            %
            % get length (aka # of children objects)
            len = obj.getLen(testCase.testProperty,'children');
            %
            % check that we get the right length
            testCase.verifyEqual(len,length(testCase.uuids);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testIsChildrenProp(testCase)
            %
            % test for function isProp
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid);
            %
            % check if property is reported as such
            res = obj.isProp(testCase.testProperty,'children');
            %
            % 
            testCase.verifyEqual(res,true);
            %
            % check for non existent property
            res = obj.isProp('nonExistentProperty,'children');
            %
            % 
            testCase.verifyEqual(res,false);

            %
            % clear memory
            testCase.manage.clearAll();
            
        end % function

        %
        function testRmChildren(testCase)
            %
            % test for function rmChild
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid);
            %
            % remove one child and check 
            res = obj.rmChild(testCase.testProperty,testCase.uuids{1});
            %
            % 
            testCase.verifyEqual(res,true);
            testCase.veirfyEqual( ...
                length(obj.mdf_def.mdf_children.(testCase.testProperty)), ...
                length(testCase.uuids)-1);

            %
            % remove all children under the same property
            res = obj.rmChild(testCase.testProperty);
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                any(ismember(obj.mdf_def.mdf_children.mdf_fields,testCase.testProperty)),
                0);
            testCase.verifyEqual( ...
                any(ismember(fields(obj.mdf_def.mdf_children.mdf_fields),testCase.testProperty)),
                0);

            % save results
            res = obj.save();
            testCase.verifyEqual(res,true);

            %
            % clear memory
            testCase.manage.clearAll();

        end % function

        %
        function testGetChildren(testCase)
            %
            % test for loading a child
            objs = mdfObj.load('mdf_type','TestObj');
            %
            % make one the child of the other
            res = objs{1}.addChild(testCase.testProperty,testCase.uuids{i});
        end % function


        %
        function testClone(testCase)
        end % function

        %
        function testGetSize(testCase)
        end % function


    end % methods
    
end % class
            
