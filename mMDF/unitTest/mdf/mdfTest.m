classdef mdfTest < matlab.unittest.TestCase
    % 
    % unit tests for mdf
    %
    % load database class, instantiate connectors classes and test
    %

    % properties
    properties
        testFolder = '';
        xmlConfFile = '';
        confStruct3 = struct();
        confStruct4 = struct();
        uuidsFile = '';
        jsonTestFile = '';
        matTestFile = '';
        jsonUuids = '';
        uuids = {};
        jsonString = '';
        jsonStructure = [];
        testStruct = [];
        objType= 'mdfTest';
        uuidPattern = '^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$';
        testUuid1 = '';
        testUuid2 = '';
        testProperty = 'testprop';
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
            testCase.xmlConfFile = fullfile(testCase.testFolder, '..', 'conf', 'mdf.xml.conf');
            testCase.uuidsFile = fullfile(testCase.testFolder, '..', 'conf', 'uuids.json');
            testCase.jsonTestFile = fullfile(testCase.testFolder, '..', 'conf', 'testJson.json');
            testCase.matTestFile = fullfile(testCase.testFolder, '..', 'conf', 'testJson.mat');
            
            % select database only configuration
            testCase.confStruct3 = struct( ...
                'confFile', testCase.xmlConfFile, ...
                'confSel', 3 );
            testCase.confStruct4 = struct( ...
                'confFile', testCase.xmlConfFile, ...
                'confSel', 4 );
            
            %
            % load obj uuids
            % load uuids
            fid = fopen(testCase.uuidsFile,'r');
            raw = fread(fid,inf);
            jsonUuids = char(raw');
            testCase.uuids = jsondecode(jsonUuids);
            
            % define 2 uuids for testing
            tempIndex = randperm(length(testCase.uuids));
            testCase.testUuid1 = testCase.uuids{tempIndex(1)};
            testCase.testUuid2 = testCase.uuids{tempIndex(2)};
            
            %
            % load test json string
            fid = fopen(testCase.jsonTestFile,'r');
            raw = fread(fid,inf);
            jsonString = char(raw');

            %
            % load equivalent matlab structure
            testCase.jsonStructure = load(testCase.matTestFile);
            
            %
            % create test struct
            testCase.testStruct = struct( ...
                'field1', 1,...
                'field2', '2' );
            
        end %function

    end %methods

    methods (TestClassTeardown)
        function destroyMdf(testCase)
            global omdfc;
            mdfConf.getInstance('release');
            mdfManage.getInstance('release');
            mdfDB.getInstance('release');
            mdf.getInstance('release');
            clear global omdfc;
        end %function
    end %methods
    
    methods
        function releaseOmdfc(testCase)
            global omdfc;
            mdfConf.getInstance('release');
            mdfManage.getInstance('release');
            mdfDB.getInstance('release');
            mdf.getInstance('release');
            clear global omdfc;
        end %function
    end %methods


    methods (Test)
        % 
        function testInstantiate(testCase)
            % 
            % just test instantiation of mdfDB
            % first it clearold instances
            testCase.releaseOmdfc();
            % instantiate new mdf class
            obj = mdf.getInstance();
            % test that we got the correct object
            testCase.verifyClass(obj,'mdf');
            % delete singleton
            mdf.getInstance('release');
        end % function

        %
        function testInit(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );
                
            % test that the configuration is a structure
            testCase.verifyClass(res,'struct');
            % check fields
            testCase.verifyEqual(isfield(res,'mdf'),true);
            testCase.verifyEqual(isfield(res,'manage'),true);
            testCase.verifyEqual(isfield(res,'conf'),true);
            testCase.verifyEqual(isfield(res,'db'),true);
            % test that we got the right type of objects
            testCase.verifyClass(res.mdf,'mdf');
            testCase.verifyClass(res.manage,'mdfManage');
            testCase.verifyClass(res.db,'mdfDB');
            testCase.verifyClass(res.conf,'mdfConf');
            
            % check global variable
            global omdfc;
            % test that the configuration is a structure
            testCase.verifyClass(omdfc,'struct');
            % check fields
            testCase.verifyEqual(isfield(omdfc,'mdf'),true);
            testCase.verifyEqual(isfield(omdfc,'manage'),true);
            testCase.verifyEqual(isfield(omdfc,'conf'),true);
            testCase.verifyEqual(isfield(omdfc,'db'),true);
            % test that we got the right type of objects
            testCase.verifyClass(omdfc.mdf,'mdf');
            testCase.verifyClass(omdfc.manage,'mdfManage');
            testCase.verifyClass(omdfc.db,'mdfDB');
            testCase.verifyClass(omdfc.conf,'mdfConf');
            

            % delete singleton)
            testCase.releaseOmdfc();
        end % function

	%
	function testTerminate(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );
            % 
	    % terminate mdf instance
	    res = mdf.terminate();

	    % check that the teminate returned 1
	    testCase.verifyEqual(res,1);
 
            % check global variable
            global omdfc;
            % test that the configuration is a structure
            testCase.verifyClass(omdfc,'struct');
            % check fields
            testCase.verifyEqual(isfield(omdfc,'mdf'),true);
            testCase.verifyEqual(isfield(omdfc,'manage'),true);
            testCase.verifyEqual(isfield(omdfc,'conf'),true);
            testCase.verifyEqual(isfield(omdfc,'db'),true);
            % test that we got the right type of objects
            testCase.verifyEqual(omdfc.mdf,[]);
            testCase.verifyEqual(omdfc.manage,[]);
            testCase.verifyEqual(omdfc.db,[]);
            testCase.verifyEqual(omdfc.conf,[]);
	    
        end % function

	    %
	    function testReinit(testCase)
            %
            % instantiate the object
            res = mdf.init( testCase.confStruct3 );
            
            % test that the configuration selected is the third one
            global omdfc
            [uname,mname,index]= omdfc.conf.getSelection();
            testCase.verifyEqual(index,3);
            testCase.verifyEqual( ...
                omdfc.db.collection, ...
                omdfc.conf.confData.configurations.configuration{testCase.confStruct3.confSel}.constants.DB.COLLECTION);
            
            % now reinit
            res = mdf.reinit( testCase.confStruct4 );
            
            % and test that the configurationselected is the fourth one
            [uname,mname,index]= omdfc.conf.getSelection();
            testCase.verifyEqual(index,4);
            testCase.verifyEqual( ...
                omdfc.db.collection, ...
                omdfc.conf.confData.configurations.configuration{testCase.confStruct4.confSel}.constants.DB.COLLECTION);

            % delete singleton)
            testCase.releaseOmdfc();
        end % function

        %
        function testUuid(testCase)
            %
            % get a uuid and check that the string is structured as one
            uuid = mdf.UUID();
            testCase.verifyEqual( ...
                regexpi( uuid, testCase.uuidPattern ), ...
                1 ...
            );

        end % function

        %
        function testC2s(testCase)
            %
            % builds a cell array of structures
            cos = { ...
                testCase.testStruct, ...
                testCase.testStruct, ...
                testCase.testStruct, ...
                testCase.testStruct, ...
                testCase.testStruct};
            
            % converts to array of structure
            res = mdf.c2s(cos);
            
            % verify
            testCase.verifyClass(res,'struct');
            testCase.verifyEqual(length(res),length(cos));
            testCase.verifyEqual( ...
                length( ...
                    intersect( ...
                        fields(res), ...
                        fields(testCase.testStruct))), ...
                length(fields(testCase.testStruct)));
        end % function
        
        %
        function testMemoryUsage(testCase)
            %
            % test the memory usage function
            [total1,used1,free1] = mdf.memoryUsage();
            
            % test that we get all numebrs and they are positive
            testCase.verifyClass(total1,'double');
            testCase.verifyClass(used1,'double');
            testCase.verifyClass(free1,'double');
            testCase.verifyGreaterThanOrEqual(total1,0);
            testCase.verifyGreaterThanOrEqual(used1,0);
            testCase.verifyGreaterThanOrEqual(free1,0);
            
            %
            % calls abreviated name function
            [total2,used2,free2] = mdf.mu();
            
            % test that we get all numebrs and they are positive
            testCase.verifyClass(total2,'double');
            testCase.verifyClass(used2,'double');
            testCase.verifyClass(free2,'double');
            testCase.verifyGreaterThanOrEqual(total2,0);
            testCase.verifyGreaterThanOrEqual(used2,0);
            testCase.verifyGreaterThanOrEqual(free2,0);
            
        end % function

        %
        function testToJson(testCase)
            %
            % test toJson function
            %
            % instantiate the object and load the test configuration file
            % we need the configuration class instantiated
            res = mdf.init( testCase.confStruct3 );
            
            % load test structure from mat file
            temp = load(testCase.matTestFile);
            
            % extract testJson structure
            testJsonStruct = temp.testJson;
            clear temp;
            
            % convert to json
            testJsonString1 = mdf.toJson(testJsonStruct);
            
            % load json string
            fid = fopen(testCase.jsonTestFile,'r');
            temp = fread(fid,inf);
            testJsonString2 = char(temp');
            
            % remove new lines and trailing spaces, just in case
            testJsonString2(strfind(testJsonString2,newline)) = [];
            testJsonString2 = deblank(testJsonString2);
            
            % check if the 2 of them are the same
            testCase.verifyEqual(testJsonString1,testJsonString2);
            
            % delete singleton)
            testCase.releaseOmdfc();            
        end % function

        %
        function testFromJson(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );

            % load json string
            fid = fopen(testCase.jsonTestFile,'r');
            temp = fread(fid,inf);
            testJsonString = char(temp');
            
            % convert json string to struct
            testJsonStruct1 = mdf.fromJson(testJsonString);
            
            % loads json struct
            % load test structure from mat file
            temp = load(testCase.matTestFile);
            
            % extract testJson structure
            testJsonStruct2 = temp.testJson;
            clear temp;
            
            % check if the 2 of them are the same
            testCase.verifyEqual(testJsonStruct1,testJsonStruct2);

            % delete singleton)
            testCase.releaseOmdfc();            
        end % function

        %
        function testCreateObjects(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );
            
            % create few mdf objects to test the relationship creation
            res = 0;
            for i = 1:length(testCase.uuids)
                % instantiate mdf object
                obj = mdfObj(testCase.objType,testCase.uuids{i});
                % add some metadata
                obj.metadata.name = ['Object ' num2str(i)];
                % save it to database
                tRes = obj.save();                
                res= res + tRes;
            end %for
            
            % verify that we were able to create all the objects
            testCase.verifyEqual(res, length(testCase.uuids));

            % delete singleton)
            testCase.releaseOmdfc();            
        end % function

        %
        function testLoad(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );
            
            % load all the objects
            objs1 = mdf.load('mdf_type',testCase.objType);
            %
            % verify that we get all the objects and they are of the
            % correct class
            testCase.verifyClass(objs1,'mdfObj');
            testCase.verifyEqual(length(objs1),length(testCase.uuids));
            
            % load just one object
            objs2 = mdf.load('mdf_uuid',testCase.testUuid1);
            %
            % verify that we get all the objects and they are of the
            % correct class
            testCase.verifyClass(objs2,'mdfObj');
            testCase.verifyEqual(length(objs2),1);
            
            % delete singleton)
            testCase.releaseOmdfc();            
        end % function

        %
        function testUnload(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );

            % load just one object
            objs = mdf.load('mdf_uuid',testCase.testUuid1);
            obj = objs(1);
            
            % unload
            mdf.unload(obj);
            
            %
            % verify that we get all the objects and they are of the
            % correct class
            testCase.verifyEqual(isvalid(obj),false);
            
            % delete singleton)
            testCase.releaseOmdfc();            
        end % function

        %
        function testGetUAO(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );
            
            %
            % get object from uuid
            [uuid,obj] = mdf.getUuidAndObject(testCase.testUuid1);
            %
            % verify that we get back a uuid and an mdfObj
            testCase.verifyClass(uuid,'char');
            testCase.verifyClass(obj,'mdfObj');
            testCase.verifyEqual( ...
                regexpi( uuid, testCase.uuidPattern ), ...
                1);
            testCase.verifyEqual(uuid,testCase.testUuid1);

            %
            % get uuid from object
            [uuid,obj] = mdf.getUuidAndObject(obj);
            %
            % verify that we get back a uuid and an mdfObj
            testCase.verifyClass(uuid,'char');
            testCase.verifyClass(obj,'mdfObj');
            testCase.verifyEqual( ...
                regexpi( uuid, testCase.uuidPattern ), ...
                1);
            testCase.verifyEqual(uuid,testCase.testUuid1);

            mdf.unload(obj);
            
            %
            % get object from uuid
            [uuid,obj] = mdf.getUAO(testCase.testUuid1);
            %
            % verify that we get back a uuid and an mdfObj
            testCase.verifyClass(uuid,'char');
            testCase.verifyClass(obj,'mdfObj');
            testCase.verifyEqual( ...
                regexpi( uuid, testCase.uuidPattern ), ...
                1);
            testCase.verifyEqual(uuid,testCase.testUuid1);

            %
            % get uuid from object
            [uuid,obj] = mdf.getUAO(obj);
            %
            % verify that we get back a uuid and an mdfObj
            testCase.verifyClass(uuid,'char');
            testCase.verifyClass(obj,'mdfObj');
            testCase.verifyEqual( ...
                regexpi( uuid, testCase.uuidPattern ), ...
                1);
            testCase.verifyEqual(uuid,testCase.testUuid1);            

            % delete singleton)
            testCase.releaseOmdfc();            
        end % function

        %
        function testApcr(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.addParentChildRelation(obj1,obj2,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                ismember(testCase.testProperty,obj1.mdf_def.mdf_children.mdf_fields),true);
            testCase.verifyEqual(length(obj1.mdf_def.mdf_children.(testCase.testProperty)),1);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_children.(testCase.testProperty).mdf_uuid, ...
                obj2.uuid);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_children.(testCase.testProperty).mdf_type, ...
                testCase.objType);
            testCase.verifyEqual(length(obj2.mdf_def.mdf_parents),1);
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_parents.mdf_uuid, ...
                obj1.uuid);
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_parents.mdf_type, ...
                testCase.objType);
            
            % clear
            om = mdfManage.getInstance();
            om.clearAll();
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.apcr(obj1,obj2,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                ismember(testCase.testProperty,obj1.mdf_def.mdf_children.mdf_fields),true);
            testCase.verifyEqual(length(obj1.mdf_def.mdf_children.(testCase.testProperty)),1);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_children.(testCase.testProperty).mdf_uuid, ...
                obj2.uuid);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_children.(testCase.testProperty).mdf_type, ...
                testCase.objType);
            testCase.verifyEqual(length(obj2.mdf_def.mdf_parents),1);
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_parents.mdf_uuid, ...
                obj1.uuid);
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_parents.mdf_type, ...
                testCase.objType);
            
            % save objects so we can use them when removing relationship
            obj1.save();
            obj2.save();
            
            % delete singleton
            om.clearAll();
            testCase.releaseOmdfc();            
        end % function
        
        %
        function testRpcr(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.rmParentChildRelation(obj1,obj2,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                ismember(testCase.testProperty,obj1.mdf_def.mdf_children.mdf_fields),false);
            testCase.verifyEqual(isfield(obj1.mdf_def.mdf_children,'testCase.testProperty'),false);
            testCase.verifyEqual(length(obj2.mdf_def.mdf_parents),0);
            
            % clear
            om = mdfManage.getInstance();
            om.clearAll();
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.rpcr(obj1,obj2,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual( ...
                ismember(testCase.testProperty,obj1.mdf_def.mdf_children.mdf_fields),false);
            testCase.verifyEqual(isfield(obj1.mdf_def.mdf_children,'testCase.testProperty'),false);
            testCase.verifyEqual(length(obj2.mdf_def.mdf_parents),0);
            
            % save objects so we can use them when removing relationship
            obj1.save();
            obj2.save();
            
            % delete singleton)
            om.clearAll();
            testCase.releaseOmdfc();            
        end % function

        %
        function testAul(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.addUnidirectionalLink(obj1,obj2,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual(length(obj1.mdf_def.mdf_links.(testCase.testProperty)),1);
            testCase.verifyEqual( ...
                any(ismember(testCase.testProperty,obj1.mdf_def.mdf_links.mdf_fields)),true);
            testCase.verifyEqual( ...
                testCase.testProperty,obj1.mdf_def.mdf_links.mdf_fields{1});
            testCase.verifyEqual( ...
                'u',obj1.mdf_def.mdf_links.mdf_directions{1});
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_uuid, ...
                obj2.uuid);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_type, ...
                testCase.objType);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_direction, ...
                'u');
            testCase.verifyEqual( ...
                any(ismember(testCase.testProperty,obj2.mdf_def.mdf_links.mdf_fields)),false);
            testCase.verifyEqual( ...
                isfield(obj2.mdf_def.mdf_links,testCase.testProperty),false);
            
            % clear
            om = mdfManage.getInstance();
            om.clearAll();
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.aul(obj1,obj2,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual(length(obj1.mdf_def.mdf_links.(testCase.testProperty)),1);
            testCase.verifyEqual( ...
                any(ismember(testCase.testProperty,obj1.mdf_def.mdf_links.mdf_fields)),true);
            testCase.verifyEqual( ...
                testCase.testProperty,obj1.mdf_def.mdf_links.mdf_fields{1});
            testCase.verifyEqual( ...
                'u',obj1.mdf_def.mdf_links.mdf_directions{1});
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_uuid, ...
                obj2.uuid);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_type, ...
                testCase.objType);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_direction, ...
                'u');
            testCase.verifyEqual( ...
                any(ismember(testCase.testProperty,obj2.mdf_def.mdf_links.mdf_fields)),false);
            testCase.verifyEqual( ...
                isfield(obj2.mdf_def.mdf_links,testCase.testProperty),false);
            
            % save objects so we can use them when removing relationship
            obj1.save();
            obj2.save();
            
            % delete singleton
            om.clearAll();
            testCase.releaseOmdfc();
        end % function

        %
        function testRul(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );

            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.rmUnidirectionalLink(obj1,obj2,testCase.testProperty);
            
            % verify that the relationship has been removed
            testCase.verifyEqual(res,true);
            testCase.verifyEqual(isfield(obj1.mdf_def.mdf_links,'testCase.testProperty'),false);
            testCase.verifyEqual( ...
                length(obj1.mdf_def.mdf_links.mdf_fields),0);
            testCase.verifyEqual( ...
                length(obj1.mdf_def.mdf_links.mdf_directions),0);
            testCase.verifyEqual(isfield(obj2.mdf_def.mdf_links,'testCase.testProperty'),false);
            testCase.verifyEqual( ...
                length(obj2.mdf_def.mdf_links.mdf_fields),0);
            testCase.verifyEqual( ...
                length(obj2.mdf_def.mdf_links.mdf_directions),0);
            
            
            % clear
            om = mdfManage.getInstance();
            om.clearAll();
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.rul(obj1,obj2,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual(isfield(obj1.mdf_def.mdf_links,'testCase.testProperty'),false);
            testCase.verifyEqual( ...
                length(obj1.mdf_def.mdf_links.mdf_fields),0);
            testCase.verifyEqual( ...
                length(obj1.mdf_def.mdf_links.mdf_directions),0);
            testCase.verifyEqual(isfield(obj2.mdf_def.mdf_links,'testCase.testProperty'),false);
            testCase.verifyEqual( ...
                length(obj2.mdf_def.mdf_links.mdf_fields),0);
            testCase.verifyEqual( ...
                length(obj2.mdf_def.mdf_links.mdf_directions),0);
            
            % save objects so we can use them when removing relationship
            obj1.save();
            obj2.save();
            
            % delete singleton)
            om.clearAll();
            testCase.releaseOmdfc();            
        end % function
        
        %
        function testAbl(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.addBidirectionalLink(obj1,obj2,testCase.testProperty,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual(length(obj1.mdf_def.mdf_links.(testCase.testProperty)),1);
            testCase.verifyEqual( ...
                ismember(testCase.testProperty,obj1.mdf_def.mdf_links.mdf_fields),true);
            testCase.verifyEqual( ...
                testCase.testProperty,obj1.mdf_def.mdf_links.mdf_fields{1});
            testCase.verifyEqual( ...
                'b',obj1.mdf_def.mdf_links.mdf_directions{1});
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_uuid, ...
                obj2.uuid);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_type, ...
                testCase.objType);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_direction, ...
                'b');
            testCase.verifyEqual(length(obj2.mdf_def.mdf_links.(testCase.testProperty)),1);
            testCase.verifyEqual( ...
                ismember(testCase.testProperty,obj2.mdf_def.mdf_links.mdf_fields),true);
            testCase.verifyEqual( ...
                testCase.testProperty,obj2.mdf_def.mdf_links.mdf_fields{1});
            testCase.verifyEqual( ...
                'b',obj2.mdf_def.mdf_links.mdf_directions{1});
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_links.(testCase.testProperty).mdf_uuid, ...
                obj1.uuid);
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_links.(testCase.testProperty).mdf_type, ...
                testCase.objType);
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_links.(testCase.testProperty).mdf_direction, ...
                'b');
            
            % clear
            om = mdfManage.getInstance();
            om.clearAll();
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.abl(obj1,obj2,testCase.testProperty,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual(length(obj1.mdf_def.mdf_links.(testCase.testProperty)),1);
            testCase.verifyEqual( ...
                ismember(testCase.testProperty,obj1.mdf_def.mdf_links.mdf_fields),true);
            testCase.verifyEqual( ...
                testCase.testProperty,obj1.mdf_def.mdf_links.mdf_fields{1});
            testCase.verifyEqual( ...
                'b',obj1.mdf_def.mdf_links.mdf_directions{1});
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_uuid, ...
                obj2.uuid);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_type, ...
                testCase.objType);
            testCase.verifyEqual( ...
                obj1.mdf_def.mdf_links.(testCase.testProperty).mdf_direction, ...
                'b');
            testCase.verifyEqual(length(obj2.mdf_def.mdf_links.(testCase.testProperty)),1);
            testCase.verifyEqual( ...
                ismember(testCase.testProperty,obj2.mdf_def.mdf_links.mdf_fields),true);
            testCase.verifyEqual( ...
                testCase.testProperty,obj2.mdf_def.mdf_links.mdf_fields{1});
            testCase.verifyEqual( ...
                'b',obj2.mdf_def.mdf_links.mdf_directions{1});
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_links.(testCase.testProperty).mdf_uuid, ...
                obj1.uuid);
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_links.(testCase.testProperty).mdf_type, ...
                testCase.objType);
            testCase.verifyEqual( ...
                obj2.mdf_def.mdf_links.(testCase.testProperty).mdf_direction, ...
                'b');
            
            % save objects so we can use them when removing relationship
            obj1.save();
            obj2.save();
            
            % delete singleton
            om.clearAll();
            testCase.releaseOmdfc();
        end % function
        
        %
        function testRbl(testCase)
            %
            % instantiate the object and load the test configuration file
            res = mdf.init( testCase.confStruct3 );

                        % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.rmBidirectionalLink(obj1,obj2,testCase.testProperty,testCase.testProperty);
            
            % verify that the relationship has been removed
            testCase.verifyEqual(res,true);
            testCase.verifyEqual(isfield(obj1.mdf_def.mdf_links,'testCase.testProperty'),false);
            testCase.verifyEqual( ...
                length(obj1.mdf_def.mdf_links.mdf_fields),0);
            testCase.verifyEqual( ...
                length(obj1.mdf_def.mdf_links.mdf_directions),0);
            testCase.verifyEqual(isfield(obj2.mdf_def.mdf_links,'testCase.testProperty'),false);
            testCase.verifyEqual( ...
                length(obj2.mdf_def.mdf_links.mdf_fields),0);
            testCase.verifyEqual( ...
                length(obj2.mdf_def.mdf_links.mdf_directions),0);
            
            
            % clear
            om = mdfManage.getInstance();
            om.clearAll();
            
            % load 2 objects and create parent child relationship
            obj1 = mdf.load('mdf_uuid',testCase.testUuid1);
            obj2 = mdf.load('mdf_uuid',testCase.testUuid2);
            
            % create relationship
            res = mdf.rbl(obj1,obj2,testCase.testProperty,testCase.testProperty);
            
            % verify that the relationship has been created
            testCase.verifyEqual(res,true);
            testCase.verifyEqual(isfield(obj1.mdf_def.mdf_links,'testCase.testProperty'),false);
            testCase.verifyEqual( ...
                length(obj1.mdf_def.mdf_links.mdf_fields),0);
            testCase.verifyEqual( ...
                length(obj1.mdf_def.mdf_links.mdf_directions),0);
            testCase.verifyEqual(isfield(obj2.mdf_def.mdf_links,'testCase.testProperty'),false);
            testCase.verifyEqual( ...
                length(obj2.mdf_def.mdf_links.mdf_fields),0);
            testCase.verifyEqual( ...
                length(obj2.mdf_def.mdf_links.mdf_directions),0);
            
            % save objects so we can use them when removing relationship
            obj1.save();
            obj2.save();
            
            % delete singleton)
            om.clearAll();
            testCase.releaseOmdfc();            
        end % function
        
    end % methods
    
end % class
            
