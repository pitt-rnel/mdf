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
        testObjIndex = -1;
        testOther ObjInde = []; 
        testMdfType = 'TestObj';
        testConfiguration = 3;
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
            % select a database data collection
            testCase.confIndata = stestCase.testObjIndexuct( ...
                    'fileName', testCase.xmlConfFile, ...
                    'automation', 'start', ...
                    'menuType', 'text', ...
                    'selection', testCase.testConfiguration);

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
                    'connect', true);
            testCase.db = mdfDb.getInstance(testCase.dbIndata);
            testCase.manage = mdfManage.getInstance();

            %
            % child property
            testCase.childProperty = 'test';

            %
            % pick the selected test object
            tempIndex = randperm(length(testCase.uuids));
            testCase.testObjIndex = tempIndex(1);
            testCase.testOtherObjIndex = tempIndex(2:end);
            tempIndex = randperm(length(testCase.uuids)-1);
            testCase.insertPosition = tempIndex(1);

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

        function obj = createMdfObjFromUuid(uuid)
            %
            % instantiate the object
            obj = mdfObj(uuid,testCase.testMdfType);
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
            % set files for this objects
            res = obj.setFiles(testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base);
            %
            % check results
            testCase.verifyEqual( res.base, '' );
            testCase.verifyEqual( res.metadata, '');
            testCase.verifyEqual( res.data, '');
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
                    'base', testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_base, ...
                    'metadata', testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_metadata, ...
                    'data', testCase.records{testCase.testObjIndex}.mdf_def.mdf_files.mdf_data));
            %
            % check results
            testCase.verifyEqual( res.base, '' );
            testCase.verifyEqual( res.metadata, '' );
            testCase.verifyEqual( res.data, '' );
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
            testCase.verifyEqual( res.base, '' );
            testCase.verifyEqual( res.metadata, '' );
            testCase.verifyEqual( res.data, '' );

            %
            % get files for this object
            res = obj.getFiles(false);
            %
            % check results
            testCase.verifyEqual( res.base, '' );
            testCase.verifyEqual( res.metadata, '' );
            testCase.verifyEqual( res.data, '' );

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
            testCase.verifyEqual( res, false );
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
            testCase.verifyEqual( res, false )
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
            
            end % for

            % check that the number of objects in the database is correct
            stats = testCase.db.getCollStat();
            verifyEqual(length(stats),1);
            verifyEqual(stats.mdfType,tesCase.testMdfType);
            verifyEqual(stats.count,length(testCase.uuids));


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
            verifyEmpty( res );

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
                    any(ismember(objs(i).uuid, testCase.uuids)), ...
                    true);
                testCase.verifyEqual( ...
                    objs(i).type, ...
                    testCase.testMdfType);
                testCase.verifyEqual( ...
                    objs(i).metadata.name, ...
                    [ testCase.testMdfType ' ' obj.uuid]);
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
                dataProperties = obj.mdf_def.mdf_data.mdf_fields;
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
            for i = tempCase.testOtherObjIndex
                res1 = obj.addChild(testCase.testProperty,testCase.uuids{i});
                res = res & res1;
            end
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                any( ...
                    ismember(testCase.testProperty, ...
                    obj.mdf_def.mdf_children.mdf_fields),
                true);
            testCase.verifyEqual( ...
                length(testCase.uuids), ...
                length(obj.mdf_def.mdf_children.(testCase.testProperty)));

            %
            % clear memory and does note save it
            testCase.manage.clearAll();

            % 
            % insert last child at a random place
            %
            % add all children excepct last
            for i = 1:length(testCase.testOtherObjIndex)-1
                res = obj.addChild( ...
                    testCase.testProperty, ...
                    testCase.uuids{testCase.testOtherObjIndex(i)}, ...
                    );
            end
            % add last child in predefind position
            res = obj.addChild( ...
                testCase.testProperty,
                testCase.uuids{testCase.testOtherObjIndex(end)},
                testCase.insertPosition);
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                length(testCase.testOtherObjIndex), ...
                length(obj.mdf_def.mdf_children.(testCase.testProperty)));
            testCase.verifyEqual( ...
                testCase.uuids{testCase.testOtherObjIndex(end)}, ...
                obj.mdf_def.mdf_children.(testCase.testProperty)(testCase.insertPosition));

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
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get vector iterator
            iter = obj.getPropIter( ...
                testCase.testProperty, ...
                'asc', ...
                'children');
            % 
            % verify that we got the right thing
            testCase.verifyEqual( ...
                iter, ...
                [1:length(obj.mdf_def.mdf_children.(testCase.testProperty))]);

            %
            % get vector iterator
            iter = obj.getPropIter(...
                testCase.testProperty, ...
                'desc', ...
                'children');
            % 
            % verify that we got the right thing
            testCase.verifyEqual( ...
                iter, ...
                [length(obj.mdf_def.mdf_children.(testCase.testProperty)):-1:1]);

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
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get uuids of the children
            uuids = obj.getUuids('children',testCase.testProperty,'default');
            %
            % check if the uuids are the same that we inserted
            testCase.verifyEqual( ...
                sort(uuids), ...
                sort(testCase.uuids(testCase.testOtherObjIndex)));

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
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get length (aka # of children objects)
            len = obj.getLen(testCase.testProperty,'children');
            %
            % check that we get the right length
            testCase.verifyEqual(len,length(testCase.testOtherObjIndex);

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
            obj = mdfObj.load(testCase.getTestObjUuid());
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
        function testGetChildren(testCase)
            %
            % test for loading a child
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % retrieve specific child
            chObj = obj.children.(testCase.testProperty)(testCase.insertPosition);
            %
            testCase.verifyClass(chObj,'mdfObj');
            testCase.verifyEqual( ...
                chObj.uuid,
                testCase.uuids{testCase.testOtherObjIndex(end)});

        end % function

        %
        function testRmOneChildren(testCase)
            %
            % test for function rmChild, removing only one child
            %
            % load object
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % remove one child and check 
            res = obj.rmChild( ...
                testCase.testProperty, ...
                testCase.uuids{testCase.testOtherObjIndex(end)});
            %
            % 
            testCase.verifyEqual(res,true);
            testCase.veirfyEqual( ...
                length(obj.mdf_def.mdf_children.(testCase.testProperty)), ...
                length(testCase.testOtherObjIndex)-1);
            %
            % clear memory
            testCase.manage.clearAll();

        end %function

        %
        function testRmAllChildren(testCase)
            %
            % test for function rmChild, removing all children under property
            %
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
 
        % ---------
        % test all methods regarding links
        %
        function testAddLinks(testCase)
            %
            % test addLink functionality
            %
            % load object 
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % add link
            res = true;
            for i = tempCase.testOtherObjIndex
                res1 = obj.addLink( ...
                    testCase.testProperty, ...
                    testCase.uuids{testCase.testOtherObjIndex(i)}, ...
                    testCase.directions(1+floor(rand(1)*2)));
                res = res & res1;
            end
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                any( ...
                    ismember(testCase.testProperty, ...
                    obj.mdf_def.mdf_children.mdf_fields),
                true);
            testCase.verifyEqual( ...
                length(testCase.testOtherObjIndex), ...
                length(obj.mdf_def.mdf_links.(testCase.testProperty)));

            %
            % clear memory and does note save it
            testCase.manage.clearAll();

            % 
            % insert last link at a random place
            %
            % add all link except last
            for i = 1:length(testCase.testOtherObjIndex)-1
                res = obj.addChild( ...
                    testCase.testProperty, ...
                    testCase.uuids{testCase.testOtherObjIndex(i)}, ...
                    testCase.directions(1+floor(rand(1)*2)));
            end
            % add last link in predefined position
            res = obj.addChild( ...
                testCase.testProperty, ...
                testCase.uuids{testCase.testOtherObjIndex(end)}, ...
                testCase.directions(1+floor(rand(1)*2)), ...
                testCase.insertPosition);
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                length(testCase.testOtherObjIndex), ...
                length(obj.mdf_def.mdf_links.(testCase.testProperty)));
            testCase.verifyEqual( ...
                testCase.uuids{testCase.testOtherObjIndex(end)}, ...
                obj.mdf_def.mdf_links.(testCase.testProperty)(testCase.insertPosition));

            % this time save the object
            res = obj.save()
            testCase.verifyEqual(res,true);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetLinksIter(testCase)
            %
            % test for function getPropIter
            %
            % load object
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get vector iterator
            iter = obj.getPropIter( ...
                testCase.testProperty, ...
                'asc', ...
                'links');
            % 
            % verify that we got the right thing
            testCase.verifyEqual( ...
                iter, ...
                [1:length(obj.mdf_def.mdf_links.(testCase.testProperty))]);

            %
            % get vector iterator
            iter = obj.getPropIter(...
                testCase.testProperty, ...
                'desc', ...
                'links');
            % 
            % verify that we got the right thing
            testCase.verifyEqual( ...
                iter, ...
                [length(obj.mdf_def.mdf_links.(testCase.testProperty)):-1:1]);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetLinksUuids(testCase)
            %
            % test for function getUuids
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get uuids of the links
            uuids = obj.getUuids('links',testCase.testProperty,'default');
            %
            % check if the uuids are the same that we inserted
            testCase.verifyEqual( ...
                sort(uuids), ...
                sort(testCase.uuids(testCase.testOtherObjIndex)));

            %
            % get uuids of the bidirectional links
            uuids = obj.getUuids('blinks',testCase.testProperty,'default');
            %
            % find uuids of bidirectional links
            mask = obj.mdf_def.mdf_links.mdf_direction == 'b';
            lUuids = obj.mdf_def.mdf_links.(testCase.testProperty)(mask);
            %
            % check if the uuids are the same that we inserted
            testCase.verifyEqual( ...
                sort(uuids), ...
                sort(lUuids));
            testCase.verifyEqual( ...
                all(ismember(uuids,testCase.uuids(testCase.testOtherObjIndex)), ...
                true);

            %
            % get uuids of the unidirectional links
            uuids = obj.getUuids('ulinks',testCase.testProperty,'default');
            %
            % find uuids of bidirectional links
            mask = obj.mdf_def.mdf_links.mdf_direction == 'u';
            lUuids = obj.mdf_def.mdf_links.(testCase.testProperty)(mask);
            %
            % check if the uuids are the same that we inserted
            testCase.verifyEqual( ...
                sort(uuids), ...
                sort(lUuids));
            testCase.verifyEqual( ...
                all(ismember(uuids,testCase.uuids(testCase.testOtherObjIndex)), ...
                true);

            %
            % get uuids of the bidirectional links
            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetLinksLen(testCase)
            %
            % test for function getLen
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get length (aka # of children objects)
            len = obj.getLen(testCase.testProperty,'links');
            %
            % check that we get the right length
            testCase.verifyEqual(len,length(testCase.testOtherObjIndex);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testIsLinkProp(testCase)
            %
            % test for function isProp
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % check if property is reported as such
            res = obj.isProp(testCase.testProperty,'links');
            %
            % 
            testCase.verifyEqual(res,true);
            %
            % check for non existent property
            res = obj.isProp('nonExistentProperty','links');
            %
            % 
            testCase.verifyEqual(res,false);

            %
            % clear memory
            testCase.manage.clearAll();
            
        end % function

        %
        function testGetLink(testCase)
            %
            % test for loading a child
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % retrieve specific link
            lObj = obj.links.(testCase.testProperty)(testCase.insertPosition);
            %
            testCase.verifyClass(chObj,'mdfObj');
            testCase.verifyEqual( ...
                lObj.uuid,
                testCase.uuids{testCase.testOtherObjIndex(end)});

        end % function

        %
        function testRmOneLink(testCase)
            %
            % test for function rmLink, removing only one link
            %
            % load object
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % remove one child and check 
            res = obj.rmLink( ...
                testCase.testProperty, ...
                testCase.uuids{testCase.testOtherObjIndex(end)});
            %
            % 
            testCase.verifyEqual(res,true);
            testCase.veirfyEqual( ...
                length(obj.mdf_def.mdf_links.(testCase.testProperty)), ...
                length(testCase.testOtherObjIndex)-1);
            %
            % clear memory
            testCase.manage.clearAll();

        end %function

        %
        function testRmAllLinks(testCase)
            %
            % test for function rmLink, removing all children under property
            %
            %
            % remove all children under the same property
            res = obj.rmLink(testCase.testProperty);
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                any(ismember(obj.mdf_def.mdf_links.mdf_fields,testCase.testProperty)),
                0);
            testCase.verifyEqual( ...
                any(ismember(fields(obj.mdf_def.mdf_links.mdf_fields),testCase.testProperty)),
                0);

            % save results
            res = obj.save();
            testCase.verifyEqual(res,true);

            %
            % clear memory
            testCase.manage.clearAll();

        end % function

        % ---------
        % test all methods regarding parents
        %
        function testAddParents(testCase)
            %
            % test addParents functionality
            %
            % load object 
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % add parents
            res = true;
            for i = tempCase.testOtherObjIndex
                res1 = obj.addLink( ...
                    testCase.uuids{testCase.testOtherObjIndex(i)});
                res = res & res1;
            end
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                any( ...
                    ismember(testCase.testProperty, ...
                    obj.mdf_def.mdf_parents.mdf_fields),
                true);
            testCase.verifyEqual( ...
                length(testCase.testOtherObjIndex), ...
                length(obj.mdf_def.mdf_parents.(testCase.testProperty)));

            % this time save the object
            res = obj.save()
            testCase.verifyEqual(res,true);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetParentsIter(testCase)
            %
            % test for function getPropIter
            %
            % load object
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get vector iterator
            iter = obj.getPropIter( ...
                '', ...
                'asc', ...
                'parents');
            % 
            % verify that we got the right thing
            testCase.verifyEqual( ...
                iter, ...
                [1:length(obj.mdf_def.mdf_parents)]);

            %
            % get vector iterator
            iter = obj.getPropIter(...
                '', ...
                'desc', ...
                'parents');
            % 
            % verify that we got the right thing
            testCase.verifyEqual( ...
                iter, ...
                [length(obj.mdf_def.mdf_links.(testCase.testProperty)):-1:1]);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetParentsUuids(testCase)
            %
            % test for function getUuids
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get uuids of the links
            uuids = obj.getUuids('parents',testCase.testProperty,'default');
            %
            % check if the uuids are the same that we inserted
            testCase.verifyEqual( ...
                sort(uuids), ...
                sort(testCase.uuids(testCase.testOtherObjIndex)));

            %
            % get uuids of the bidirectional links
            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetParentsLen(testCase)
            %
            % test for function getLen
            %
            % load object                        
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get length (aka # of children objects)
            len = obj.getLen('','parents');
            %
            % check that we get the right length
            testCase.verifyEqual(len,length(testCase.testOtherObjIndex);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetParent(testCase)
            %
            % test for loading a child
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % retrieve specific link
            pObj = obj.getParent(testCase.insertPosition);
            %
            testCase.verifyClass(pObj,'mdfObj');
            testCase.verifyEqual( ...
                pObj.uuid, ...
                testCase.uuids{testCase.testOtherObjIndex(end)});

            %
            % retrieve specific link by uuid
            pObj = obj.getParent( ...
                testCase.uuids{testCase.testOtherObjIndex(end)});
            %
            testCase.verifyClass(pObj,'mdfObj');
            testCase.verifyEqual( ...
                pObj.uuid, ...
                testCase.uuids{testCase.testOtherObjIndex(end)});


            %
            % retrieve specific link by uuid
            pObjs = obj.getParent( ...
                struct( ...
                    'mdf_type', testCase.testMdfType));
            %
            testCase.verifyClass(pObjs,'mdfObj');
            testCase.verifyEqual( ...
                sort(pObjs.uuid), ...
                sort(testCase.uuids{testCase.testOtherObjIndex}));

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testRmOneParent(testCase)
            %
            % test for function rmParent, removing only one link
            %
            % load object
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % remove one child and check 
            res = obj.rmParent( ...
                testCase.uuids{testCase.testOtherObjIndex(end)});
            %
            % 
            testCase.verifyEqual(res,true);
            testCase.veirfyEqual( ...
                length(obj.mdf_def.mdf_parents), ...
                length(testCase.testOtherObjIndex)-1);
            %
            % clear memory
            testCase.manage.clearAll();

        end %function

        %
        function testRmAllParents(testCase)
            %
            % test for function rmParents, removing all children under property
            %
            % load object
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % remove all children under the same property
            res = obj.rmParent();
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                length(obj.mdf_def.mdf_parents),
                0);

            % save results
            res = obj.save();
            testCase.verifyEqual(res,true);

            %
            % clear memory
            testCase.manage.clearAll();

        end % function

        %
        function testClone(testCase)
            %
            % test for function clone
            %
            % load object
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % clone object
            cObj = obj.clone();
            %
            % check that everything has been ported
            testCase.verifyEqual(cObj.type,obj.type);
            testCase.verifyNotEqual(cObj.uuid,obj.uuid);
            testCase.verifyEqual(cObj.data,obj.data);

            %
            % clear memory
            testCase.manage.clearAll();
        end % function

        %
        function testGetSize(testCase)
            %
            % test for function getSize
            %
            % load object
            obj = mdfObj.load(testCase.getTestObjUuid());
            %
            % get total size
            totalSize = obj.getSize();
            %
            % check that is a positive integer
            testCase.verifyClass(totalSize,'double');
            testCase.verifyEqual(totalSize,floor(totalSize));
            testCase.verifyGreatThan(totalSize,0);

            %
            % get detailed size
            sizes = obj.getSize(true);
            %
            % check that is a positive integer
            testCase.verifyClass(totalSize,'struct');
            sizeFields = fields(sizes);
            for i = 1:length(sizeFields)
                fn = sizeFields{i};
                testCase.verifyClass(sizes.(fn),'double');
                testCase.verifyEqual(sizes.(fn),floor(sizes.(fn)));
                testCase.verifyGreatThan(sizes.(fn),0);
            end %for

            %
            % clear memory
            testCase.manage.clearAll();

        end % function

        %
        function testDeleteObjects()
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
                obj.remove();
                % 
                % check that the dbentry is removed
                obj = mdfObj.load(testCase.uuids{i});
                testCase.verifyEmpty(obj);
            end %for

        end % function

    end % methods
    
end % class
            
