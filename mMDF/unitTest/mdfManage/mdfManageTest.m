classdef mdfManageTest < matlab.unittest.TestCase
    % 
    % unit tests for mdfManage
    %
    % creates an array of fake mdfObj for testing purposes
    %

    % properties
    properties
        uuids = {};
        files = {};
        mdfObjs = [];
        noos = -1;
        selection1 = [];
        selection2 = [];
        clearSelection1 = {};
        clearSelection2 = [];
        index1 = -1;
        index2 = -1;
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
            %testCase.testFolder = cpfp;
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
            testCase.uuids = { ...
                '520e9866-ad4a-11e8-ac5b-1b25bbe857ae', ...
                '520ef3ba-ad4a-11e8-af6a-676b18d07451', ...
                '520f512a-ad4a-11e8-a2b0-a73928053455', ...
                '520fa67a-ad4a-11e8-9c9f-d7696f0d32c1', ...
                '520ffc60-ad4a-11e8-9ca2-9bdaea413e98', ...
                '521055e8-ad4a-11e8-bf12-efcd534f865b', ...
                '5210b754-ad4a-11e8-b05f-f390c0fe1a5e', ...
                '52110b6e-ad4a-11e8-98af-ff9806b0e8ab', ...
                '52115df8-ad4a-11e8-b014-dbb3c08e7fa0', ...
                '5211b21c-ad4a-11e8-8d8e-c3c1540184e9'};

            %
            % instantiate fake mdfObj
            testCase.mdfObjs = mdfObj('first_fake_object_to define_type');
            for i = 1:length(testCase.uuids)
                testCase.mdfObjs(end+1) = mdfObj(testCase.uuids{i});
                testCase.files{end+1} = ['mdfObj_' testCase.uuids{i} '.test'];
            end %for
            testCase.mdfObjs(1) = [];

            %
            % numberof objects defined by the test class
            testCase.noos = length(testCase.mdfObjs);

            %
            % define the order in which we should insert the objects
            testCase.selection1 = randperm(testCase.noos);
            %
            % remove the last element for the exclude test
            testCase.selection2 = testCase.selection1(1:end-1);

            %
            % index of the element for inclusion test
            testCase.index1 = testCase.selection1(floor(length(testCase.selection1)/2));
            % index of the element for exclusion test
            testCase.index2 = testCase.selection1(end); 
            
            % clear selections
            for i = testCase.selection1
                if mod(i,2)
                    testCase.clearSelection1{i} = testCase.uuids{i};
                else
                    testCase.clearSelection1{i} = testCase.mdfObjs(i);
                end %if
            end %for
            testCase.clearSelection2 = testCase.mdfObjs(testCase.selection1);
        end %function
    end %methods

    methods (TestClassTeardown)
        function destroyMdfConf(testCase)
            global omdfc;
            delete(omdfc.manage);
            clear omdfc;
        end %function
    end %methods

    methods
        
        function res = insertAllMdfObj(testCase,obj,varargin)
            % function res = testCase.insertAllMdfObj(obj,indexes)
            %
            %
            % check if we got the index of objects to insert
            indeces = [1:testCase.noos];
            if nargin > 2
                indeces = varargin{1};
            end %if
            % create and insert all fake mdfObj defined and requested in the test class
            res = [];
            for i = indeces
                res(end+1) = obj.insert( ...
                    testCase.uuids{i}, ...
                    testCase.files{i}, ...
                    testCase.mdfObjs(i));
            end %for
        end %function

        function res = replenishMdfObjects(testCase)
            res = 0;
            for i = 1:testCase.noos
                if ~isvalid(testCase.mdfObjs(i))
                    testCase.mdfObjs(i) = mdfObj(testCase.uuids{i});
                    res = res + 1;
                end %if
            end %for
            testCase.clearSelection2 = testCase.mdfObjs(testCase.selection1);
        end %function
    end %methods

    methods (Test)
        % 
        function testInstantiate(testCase)
            % 
            % just test instantiation of mdfDB
            obj = mdfManage.getInstance();
            % test that we got the correct object
            testCase.verifyClass(obj,'mdfManage');
            % delete singleton
            mdfManage.getInstance('release');
        end % function

        %
        function testConfiguration(testCase)
            %
            % instantiate the object
            obj = mdfManage.getInstance();
            % test that the buffer is empty
            testCase.verifyEqual(length(obj.object),0);
            testCase.verifyEqual(length(obj.uuid),0);
            testCase.verifyEqual(length(obj.file),0);

            % delete singleton)
            mdfManage.getInstance('release');
        end % function

        %
        function testInsertMany(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj);
  
            % check if buffer size is correct 
            testCase.verifyEqual(length(obj.object),testCase.noos);
            testCase.verifyEqual(length(obj.uuid),testCase.noos);
            testCase.verifyEqual(length(obj.file),testCase.noos);

            % delete singleton
            mdfManage.getInstance('release');
        end % function

        %
        function testUsage(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
  
            % check if buffer size is correct 
            testCase.verifyEqual(obj.usage(),0);
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj);
  
            % check if buffer size is correct 
            testCase.verifyEqual(obj.usage(),testCase.noos);

            % delete singleton
            mdfManage.getInstance('release');
            
        end %function

        %
        function testIndexByUuid(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);

            % get one object at index 5 and check that is the correct one 
            index = obj.indexByUuid(testCase.uuids{testCase.index1});
            % check if buffer size is correct 
            testCase.verifyNotEmpty(index);
            testCase.verifyEqual(index,find(testCase.selection1 == testCase.index1));

            % get one object at index 5 and check that is the correct one 
            index = obj.indexByUuid(testCase.uuids{testCase.index2});
            % check if buffer size is correct 
            testCase.verifyEmpty(index);

            % delete singleton
            mdfManage.getInstance('release');
            
        end % function

        %
        function testIndexByFile(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);

            % get one object at index 5 and check that is the correct one 
            index = obj.indexByFile(testCase.files{testCase.index1});
            % check if buffer size is correct 
            testCase.verifyNotEmpty(index);
            testCase.verifyEqual(index,find(testCase.selection1 == testCase.index1));

            % get one object at index 5 and check that is the correct one 
            index = obj.indexByUuid(testCase.files{testCase.index2});
            % check if buffer size is correct 
            testCase.verifyEmpty(index);

            % delete singleton
            mdfManage.getInstance('release');
            
        end % function

        %
        function testIndex(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);
            
            %
            correctIndex = find(testCase.selection1 == testCase.index1);
            
            % get index passing in the object
            % and check if index is correct
            index = obj.index(testCase.mdfObjs(testCase.index1));
            testCase.verifyNotEmpty(index);
            testCase.verifyEqual(index,correctIndex);

            % get index passing in the uuid
            % and check if index is correct
            index = obj.index(testCase.uuids{testCase.index1});
            testCase.verifyNotEmpty(index);
            testCase.verifyEqual(index,correctIndex);

            % get index passing in the file
            % and check if index is correct
            index = obj.index(testCase.files{testCase.index1});
            testCase.verifyNotEmpty(index);
            testCase.verifyEqual(index,correctIndex);

            % get index passing in a struct
            % and check if index is correct
            index = obj.index( ...
                struct( ...
                    'uuid', testCase.uuids{testCase.index1}));
            testCase.verifyNotEmpty(index);
            testCase.verifyEqual(index,correctIndex);

            % get index passing in a struct
            % and check if index is correct
            index = obj.index( ...
                struct( ...
                    'file', testCase.files{testCase.index1}));
            testCase.verifyNotEmpty(index);
            testCase.verifyEqual(index,correctIndex);

            % get index passing in the object
            % and check if index is correct
            index = obj.index(testCase.mdfObjs(testCase.index2));
            testCase.verifyEmpty(index);

            % get index passing in the uuid
            % and check if index is correct
            index = obj.index(testCase.uuids{testCase.index2});
            testCase.verifyEmpty(index);

            % get index passing in the file
            % and check if index is correct
            index = obj.index(testCase.files{testCase.index2});
            testCase.verifyEmpty(index);

            % get index passing in a struct
            % and check if index is correct
            index = obj.index( ...
                struct( ...
                    'uuid', testCase.uuids{testCase.index2}));
            testCase.verifyEmpty(index);

            % get index passing in a struct
            % and check if index is correct
            index = obj.index( ...
                struct( ...
                    'file', testCase.files{testCase.index2}));
            testCase.verifyEmpty(index);

            % delete singleton
            mdfManage.getInstance('release');

        end %function

        function testExistByUuid(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);

            % get one object at index 5 and check that is the correct one 
            res = obj.existByUuid(testCase.uuids{testCase.index1});
            testCase.verifyEqual(res,true);
            
            % get one object at index 5 and check that is the correct one 
            res = obj.existByUuid(testCase.uuids{testCase.index2});
            testCase.verifyEqual(res,false);

            % delete singleton
            mdfManage.getInstance('release');
            
        end % function

        %
        function testExistByFile(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);

            % get one object at index 5 and check that is the correct one 
            res = obj.existByFile(testCase.files{testCase.index1});
            testCase.verifyEqual(res,true);

            % get one object at index 5 and check that is the correct one 
            res = obj.existByFile(testCase.files{testCase.index2});
            testCase.verifyEqual(res,false);

            % delete singleton
            mdfManage.getInstance('release');
            
        end % function

        %
        function testExist(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);
            
            % get index passing in the object
            % and check if index is correct
            res = obj.exist(testCase.mdfObjs(testCase.index1));
            testCase.verifyEqual(res,true);

            % get index passing in the uuid
            % and check if index is correct
            res = obj.exist(testCase.uuids{testCase.index1});
            testCase.verifyEqual(res,true);

            % get index passing in the file
            % and check if index is correct
            res = obj.exist(testCase.files{testCase.index1});
            testCase.verifyEqual(res,true);

            % get index passing in a struct
            % and check if index is correct
            res = obj.exist( ...
                struct( ...
                    'uuid', testCase.uuids{testCase.index1}));
            testCase.verifyEqual(res,true);

            % get index passing in a struct
            % and check if index is correct
            res = obj.exist( ...
                struct( ...
                    'file', testCase.files{testCase.index1}));
            testCase.verifyEqual(res,true);

            % get index passing in the object
            % and check if index is correct
            res = obj.exist(testCase.mdfObjs(testCase.index2));
            testCase.verifyEqual(res,false);

            % get index passing in the uuid
            % and check if index is correct
            res = obj.exist(testCase.uuids{testCase.index2});
            testCase.verifyEqual(res,false);

            % get index passing in the file
            % and check if index is correct
            res = obj.exist(testCase.files{testCase.index2});
            testCase.verifyEqual(res,false);

            % get index passing in a struct
            % and check if index is correct
            res = obj.exist( ...
                struct( ...
                    'uuid', testCase.uuids{testCase.index2}));
            testCase.verifyEqual(res,false);

            % get index passing in a struct
            % and check if index is correct
            res = obj.exist( ...
                struct( ...
                    'file', testCase.files{testCase.index2}));
            testCase.verifyEqual(res,false);

            % delete singleton
            mdfManage.getInstance('release');

        end %function
        
        %
        function testGet(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);
            %
            % retrieve inserted object
            res = obj.get(testCase.mdfObjs(testCase.index1));
            testCase.verifyClass(res,'mdfObj');
            testCase.verifyEqual(res,testCase.mdfObjs(testCase.index1));

            %
            res = obj.get(testCase.uuids{testCase.index1});
            testCase.verifyClass(res,'mdfObj');
            testCase.verifyEqual(res,testCase.mdfObjs(testCase.index1));

            %
            res = obj.get(testCase.files{testCase.index1});
            testCase.verifyClass(res,'mdfObj');
            testCase.verifyEqual(res,testCase.mdfObjs(testCase.index1));

            %
            res = obj.get( ...
                struct( ...
                    'uuid', testCase.uuids{testCase.index1}));
            testCase.verifyClass(res,'mdfObj');
            testCase.verifyEqual(res,testCase.mdfObjs(testCase.index1));

            %
            res = obj.get( ...
                struct( ...
                    'file', testCase.files{testCase.index1}));
            testCase.verifyClass(res,'mdfObj');
            testCase.verifyEqual(res,testCase.mdfObjs(testCase.index1));

            %
            res = obj.get(testCase.mdfObjs(testCase.index2));
            testCase.verifyEqual(res,[]);

            %
            res = obj.get(testCase.uuids{testCase.index2});
            testCase.verifyEqual(res,[]);

            %
            res = obj.get(testCase.files{testCase.index2});
            testCase.verifyEqual(res,[]);

            %
            res = obj.get( ...
                struct( ...
                    'uuid', testCase.uuids{testCase.index2}));
            testCase.verifyEqual(res,[]);

            %
            res = obj.get( ...
                struct( ...
                    'file', testCase.files{testCase.index2}));
            testCase.verifyEqual(res,[]);

            % delete singleton
            mdfManage.getInstance('release');

        end %function

        %
        function testInsert(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);
            %
            % insert object already inserted
            pos1 = obj.index(testCase.mdfObjs(testCase.index1));
            len1 = obj.usage();
            pos2 = obj.insert( ...
                testCase.uuids{testCase.index1}, ...
                testCase.files{testCase.index1}, ...
                testCase.mdfObjs(testCase.index1) ...
            );
            testCase.verifyEqual(pos1,pos2);
            testCase.verifyEqual(len1,obj.usage());

            % insert new object
            len1 = obj.usage();
            pos2 = obj.insert( ...
                testCase.uuids{testCase.index2}, ...
                testCase.files{testCase.index2}, ...
                testCase.mdfObjs(testCase.index2) ...
            );
            testCase.verifyGreaterThan(pos2,len1);
            testCase.verifyEqual(len1+1,obj.usage());

            % delete singleton
            mdfManage.getInstance('release');

        end %function

        %
        function testRemoveByIndex(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);
            %
            % get index for one inserted object
            ind1 = obj.index(testCase.mdfObjs(testCase.index1));
            %
            % save how many object we have in memory
            len1 = obj.usage();
            %
            % attempt to remove the selected object
            res = obj.removeByIndex(ind1);
            testCase.verifyEqual(res,true);
            testCase.verifyLessThan(obj.usage(),len1);

            % delete singleton
            mdfManage.getInstance('release');

        end %function
       
        %
        function testRemove(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);
            %
            % save how many object we have in memory
            len1 = obj.usage();
            %
            % attempt to remove the selected object
            res = obj.remove(testCase.mdfObjs(testCase.index1));
            testCase.verifyEqual(res,true);
            testCase.verifyLessThan(obj.usage(),len1);

            % remove object not in memory
            %
            % save how many object we have in memory
            len1 = obj.usage();
            %
            % attempt to remove the selected object
            res = obj.remove(testCase.mdfObjs(testCase.index2));
            testCase.verifyEqual(res,false);
            testCase.verifyEqual(obj.usage(),len1);
            
            % delete singleton
            mdfManage.getInstance('release');

        end %function

        %
        function testClear_1(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();

            %
            % make sure that all the fake mdfObj are still valid
            % or creates new ones
            testCase.replenishMdfObjects();

            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection1);

            % get number of object managed
            len1 = obj.usage();

            % remove one object
            res = obj.clear(testCase.clearSelection1{1});
            testCase.verifyEqual(res,1);
            testCase.verifyEqual(obj.usage(),len1-1);

            % delete singleton
            mdfManage.getInstance('release');

        end %function

        %
        function testClear_2(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();

            %
            % make sure that all the fake mdfObj are still valid
            % or creates new ones
            testCase.replenishMdfObjects();

            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection1);

            % remove all objects
            res = obj.clear(testCase.clearSelection1);
            testCase.verifyEqual(res,testCase.noos);
            testCase.verifyEqual(obj.usage(),0);

            % delete singleton
            mdfManage.getInstance('release');

        end %function
        
        %
        function testClear_3(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();

            %
            % make sure that all the fake mdfObj are still valid
            % or creates new ones
            testCase.replenishMdfObjects();

            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection1);

            % remove one object
            res = obj.clear(testCase.clearSelection2);
            testCase.verifyEqual(res,testCase.noos);
            testCase.verifyEqual(obj.usage(),0);

            % delete singleton
            mdfManage.getInstance('release');

        end %function

        %
        function testClearAll(testCase)
            %
            % instantiate the object and load the configuration
            obj = mdfManage.getInstance();

            %
            % make sure that all the fake mdfObj are still valid
            % or creates new ones
            testCase.replenishMdfObjects();
            
            %
            % insert test objects
            res = testCase.insertAllMdfObj(obj,testCase.selection2);

            % save usage
            usage1 = obj.usage();

            % clear all object
            res = obj.clearAll();
            testCase.verifyEqual(res,usage1);
            testCase.verifyEqual(obj.usage(),0);

            % delete singleton
            mdfManage.getInstance('release');

        end %function

    end % methods
    
end % class
            
