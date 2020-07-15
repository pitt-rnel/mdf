classdef mdfMongoDB_Metadata < mdfStorageConnector

    properties (Constant)
        Jar =  '../../../java/mongo-java-driver-3.8.0.jar';
        SchemaFunctionFile = '../../../javascript/mdfDbSchema.js';
        DEFAULT_HOST = 'localhost';
        DEFAULT_PORT = '27017';
        DEFAULT_DATABASE = 'mdf_metadata';
        DEFAULT_COLLECTION = 'mdf_metadata';
    end  

    properties
        % configuration in base class

        % connection info
        % main database
        cHost = '';
        cPort = [];
        cDatabase = [];
        cCollection = [];

        % connection objects for def and metadata
        oMongo = [];
        oDatabase= [];
        oCollection = [];

        % variable containing the javascript code to get the collection
        % schema
        jsSchemaFunction = '';
    end

    methods (Static)
        %
        function res = getCS()
            % return the connection string for this class
            res = "MONGODB_METADATA";
        end %function
    end %methods

    methods
        function obj = mdfMongoDB_Metadata(configuration)
            % class constructor

            % set default values
            obj.cHost = obj.DEFAULT_HOST;
            obj.cPort = obj.DEFAULT_PORT;
            obj.cDatabase = obj.DEFAULT_DATABASE;
            obj.cCollection = obj.DEFAULT_COLLECTION;

            if nargin > 0
                % save configuration
                obj.configuration = configuration;
    
                % make sure to extract the database connection info
                obj.setDbInfo();

                % connects to the database if needed
                obj.connect(conf);
            end %if
            
            % load the javascript code to get the collection schema
            if ~isempty(obj.collection)
                % get current folder
                [cf,~,~] = fileparts(mfilename('fullpath'));
                % build full path to schema file
                fp = fullfile(cf,obj.SchemaFunctionFile);
                % loads file
                fid = fopen(fp);
                obj.jsSchemaFunction = strrep(char(fread(fid,inf)'),'<COLLECTION>',obj.collection);
                fclose(fid);
            end %if
        end %function
    end

    methods
        setDbInfo(obj,configuration);
        res = isValidCollection(obj);
        res = isValidConnection(obj);
        res = isValidDatabase(obj);
        res = isValid(obj)

        res = rawInsert(obj,query)
        res = rawInsertMany(obj,query)        
        res = rawUpdate(obj,query,values,upsert)
        res = getCollStats(obj,varargin)
        res = aggregate(obj,pipeline)
        res = mapReduce(obj,map,reduce,options)
        
        outobj = toBasicDBObject(obj,inobj)
        outobj = toBsonDocument(obj,inobj)
        
        [res, ed] = validateRelationships(obj)
        [res, ed] = validateUuids(obj)
        [res, stats, res] = validateSchema(obj)
    end
    
    methods (Static)
        output = prepQuery(input)
    end %methods static
end

