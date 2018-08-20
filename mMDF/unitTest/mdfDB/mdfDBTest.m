classdef mdfDBTest < matlab.unittest.TestCase
    % 
    % unit tests for mdfDB
    %
    % load database class, instantiate connectors classes and test
    %

    % properties
    properties
        configuration = '';
        testFolder = '';
        recordFolder = 'records/minimized';
        recordFiles = {};
        records = {};
        recordTypes = {};
        recordUniqueTypes = {};
        recordQuantity = [];
        aggregationPipeline = {};
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
            % set test configuration
            testCase.configuration = struct( ...
                 'human_name', 'mdfDB test collection 1', ...
                 'machine_name', 'metadata_test_collection_1', ...
                 'host' ,'127.0.0.1', ...
                 'port', 15213, ...
                 'database', 'mdfDbTest', ...
                 'collection', 'mdfDbTest', ...
                 'connect', 0);
            %
            % add dull path to folder where test records are located
            testCase.recordFolder = fullfile(testCase.testFolder,testCase.recordFolder);
            %
            % listall the json files and extract just the names
            testCase.recordFiles = arrayfun( ...
                @(item)(fullfile(testCase.recordFolder,item.name)), ...
                dir(fullfile(testCase.recordFolder,'*.json')), ...
                'UniformOutput',0);
            
            % load all the records
            for i = [1:length(testCase.recordFiles)]
                jsonText = fileread(testCase.recordFiles{i});
                testCase.records{i} = jsondecode(jsonText);
            end %for

                        %
            % prepare additional data for tests
            testCase.recordTypes = cellfun( ...
                @(item) item.mdf_def.mdf_type, ...
                testCase.records, ...
                'UniformOutput',0);
            testCase.recordUniqueTypes = unique(testCase.recordTypes,'stable');
            testCase.recordQuantity = cell2mat( ...
                cellfun( ...
                    @(x) sum(ismember(testCase.recordTypes,x)), ...
                    testCase.recordUniqueTypes, ...
                    'UniformOutput',0));

            % prepare the aggregation pipeline
            testCase.aggregationPipeline = { ...
              '{ $project : { "mdf_uuid" : "$mdf_def.mdf_uuid", "mdf_type" : "$mdf_def.mdf_type" }}',  ...   
              '{ $group : { "_id" : "$mdf_type", "count" : { $sum : 1 }, "uuids" : { $addToSet : "$mdf_uuid" }}}', ...
              '{ $project : { "_id" : 0, "type" : "$_id", "count" : 1, "uuids" : 1}}' };

        end %function

        %
        function createMdfConf(testCase)
            % instantiate a mock mdfConf, so we can run the tests
            % 

            global omdfc;
            omdfc.conf = mdfConf();

        end %function
    end %methods

    methods (TestClassTeardown)
        function destroyMdfConf(testCase)
            global omdfc;
            delete(omdfc.conf);
            clear omdfc;
        end %function
    end %methods


    methods (Test)
        % 
        function testInstantiate(testCase)
            % 
            % just test instantiation of mdfDB
            obj = mdfDB.getInstance();
            % test that we got the correct object
            testCase.verifyClass(obj,'mdfDB');
            % delete singleton
            mdfDB.getInstance('release');
        end % function

        %
        function testConfiguration(testCase)
            %
            % instantiate the object and load the test configuration file
            obj = mdfDB.getInstance(testCase.configuration);
            % test that the configuration is a structure
            testCase.verifyClass(obj.host,'char');
            testCase.verifyClass(obj.port,'double');
            testCase.verifyClass(obj.database,'char');
            testCase.verifyClass(obj.collection,'char');
            % test that the db object has the test configuration 
            testCase.verifyEqual(obj.host,testCase.configuration.host);
            testCase.verifyEqual(obj.port,testCase.configuration.port);
            testCase.verifyEqual(obj.database,testCase.configuration.database);
            testCase.verifyEqual(obj.collection,testCase.configuration.collection);

            % delete singleton)
            mdfDB.getInstance('release');
        end % function

        %
        function testConnect(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % connect to container db object using index
            obj.connect();
            %
            % test that there is one container, that's what the test configuration says
            testCase.verifyClass(obj.db,'com.mongodb.client.internal.MongoDatabaseImpl');
            testCase.verifyClass(obj.coll,'com.mongodb.client.internal.MongoCollectionImpl');
            %
            % test that the uuid is the same
            testCase.verifyEqual(obj.isValidConnection,true);

            % delete singleton
            mdfDB.getInstance('release');
        end % function

        %
        function testDeleteAllEmpty(testCase)
            % 
            % instantiate the object and load configuration
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % connect to container db object using index
            obj.connect();
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % test that res is a number
            testCase.verifyClass(res,'double');
            testCase.verifyGreaterThanOrEqual(res,0);

            % delete singleton
            mdfDB.getInstance('release');
  
        end %function

        %
        function testInsert(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % insert records
            res = obj.insert(testCase.records);
            
            % make sure that the insert returns 1
            testCase.verifyEqual(res,length(testCase.records));
            
            % delete singleton
            mdfDB.getInstance('release');
        end % function

        %
        function testInsertMany(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % insert records
            res = obj.insertMany(testCase.records);
            
            % make sure that the insert returns 1
            testCase.verifyEqual(res,1);
            
            % delete singleton
            mdfDB.getInstance('release');
        end % function

        %
        function testFind(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % insert records
            res = obj.insert(testCase.records);

            %
            % find record
            query = ['{ "mdf_def.mdf_uuid" : "' testCase.records{1}.mdf_def.mdf_uuid '" }'];
            res = obj.find(query);
            
            %
            % check if we got back a cell array of struct
            testCase.verifyClass(res,'cell');
            testCase.verifyClass(res{1},'struct');
            
            %
            % compare records
            testCase.verifyEqual(res{1},testCase.records{1});
            
        end %function

        %
        function testUpdate(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % prepare query
            query = ['{ "mdf_def.mdf_uuid" : "' testCase.records{1}.mdf_def.mdf_uuid '" }'];
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % insert record
            res = obj.insert(testCase.records);
            %
            % change record
            record = testCase.records{1};
            record.mdf_def.mdf_modified = datestr(now,'yyyy-mm-dd HH:MM:SS');
            %
            % update record
            res = obj.update(...
                query, ...
                record, ...
                true);
            
            % check that update operation worked accordingly
            testCase.verifyEqual(res,1);
            
            %
            % find record
            res = obj.find(query);
            
            %
            % check if we got back a cell array of struct
            testCase.verifyClass(res,'cell');
            testCase.verifyClass(res{1},'struct');
            
            %
            % compare records
            testCase.verifyEqual(res{1},record);

            % delete singleton
            mdfDB.getInstance('release');
        end %function

        %
        function testDelete(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % insert records
            res = obj.insert(testCase.records);
            %
            % delete one entry
            res = obj.remove(['{ "mdf_def.mdf_uuid" : "' testCase.records{1}.mdf_def.mdf_uuid '"}']);
            %
            % check that we deleted only one record
            testCase.verifyClass(res,'double');
            testCase.verifyEqual(res,1);
            %
            % delete singleton
            mdfDB.getInstance('release');
        end %function

        %
        function testAggregation(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % insert records
            res = obj.insert(testCase.records);
            %
            % execute the aggregation
            res = obj.aggregate(testCase.aggregationPipeline);
            %
            % test results
            testCase.verifyClass(res,'cell');
            testCase.verifyEqual(length(res),length(testCase.recordUniqueTypes));
            for i = 1:length(res)
                % find if type is correct
                index = find(strcmp(testCase.recordUniqueTypes,res{i}.type));
                if ~isempty(i)
                    testCase.verifyEqual(res{i}.count,testCase.recordQuantity(index));
                else
                    testCase.verifyEqual(res{i}.type,'unknown');
                end %if
            end %for     
            %
            % delete singleton
            mdfDB.getInstance('release');
        end %testAggregate

        %
        function testCollStats(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % insert records
            res = obj.insert(testCase.records);
            %
            % run coll stats
            res = obj.getCollStats();
            %
            % check results
            testCase.verifyClass(res,'struct');
            testCase.verifyEqual(length(res),length(testCase.recordUniqueTypes));
            for i = 1:length(res)
                j = find(strcmp(testCase.recordUniqueTypes,res(i).mdf_type),1);
                testCase.verifyEqual(res(i).mdf_type,testCase.recordUniqueTypes{j});
                testCase.verifyEqual(res(i).value,testCase.recordQuantity(j));
            end %for
            %
            % delete singleton
            mdfDB.getInstance('release');
        end %function

        %
        function testValidateRelationships(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % insert records
            res = obj.insert(testCase.records);
            %
            % run relationship validation
            res = obj.validateRelationships();
            %
            % test that res is false as the data have few missing links
            testCase.verifyEqual(res,false);

            %
            % run relationship validation and request additional data
            [res, ed] = obj.validateRelationships();
            %
            % test that res is false as the data have few missing links
            testCase.verifyEqual(res,false);
            testCase.verifyEqual(length(ed.parentChild.missingChild),1);
            testCase.verifyEqual(length(ed.parentChild.missingParent),1);
            testCase.verifyEqual(length(ed.parentChild.missingBidirectionality),1);
            testCase.verifyEqual(length(ed.bidirectional.missingDestination),1);
            testCase.verifyEqual(length(ed.bidirectional.missingBidirectionality),1);
            testCase.verifyEqual(length(ed.unidirectional.missingDestination),0);
            %
            % delete singleton)
            mdfDB.getInstance('release');
        end %function

        % 
        function testValidationUuid(testCase)
            %
            % instantiate class and connect to db
            obj = mdfDB.getInstance(testCase.configuration);
            obj.connect();
            %
            % delete all entries
            res = obj.remove('{}');
            %
            % insert records
            res = obj.insert(testCase.records);
            %
            % run relationship validation
            res = obj.validateUuids();
            %
            % run validate uuid function
            testCase.verifyClass(res,true);
            %
            % run relationship validation
            [res, ed] = obj.validateUuids();
            %
            % test results
            testCase.verifyClass(res,true);
            testCase.verifyEqual(length(ed),1);
            testCase.verifyEqual(ed(1).uuid,testCase.records{end}.mdf_def.mdf_uuid);
            testCase.verifyEqual(ed(1).count,2);
            %
            % delete singleton)
            mdfDB.getInstance('release');
        end %function

        %
        function testValidationKeys(testCase)
            % test single habitat
            obj = mdfDB.getInstance(testCase.configuration);
            %
            % load test environment
            
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
            mdfDB.getInstance('release');
        end %function
        
    end % methods
    
end % class
            
