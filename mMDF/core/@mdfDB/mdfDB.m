classdef (Sealed) mdfDB < handle

    properties (Constant)
        Jar =  '../../../java/mongo-java-driver-3.2.1.jar';
        DEFAULT_HOST = 'localhost';
        DEFAULT_PORT = 27017;
        DEFAULT_DATABASE = 'mdf';
        DEFAULT_COLLECTION = 'mdf';
    end  

    properties
        % connection info
        host = '';
        port = [];
        database = [];
        collection = [];
        % connection objects
        m = [];
        db = [];
        coll = [];
    end

    methods (Access = private)
        function obj = mdfDB
        end
    end
    methods (Static)
        function singleObj = getInstance(conf)
            mlock;
            % use a persistent variable to mantain the instance
            persistent localObj
            % check if the persisten object is actually an object and is
            % valid
            if isempty(localObj) || ~isvalid(localObj)
                % instantiate new object
                localObj = mdfDB;
            end %if
            
            % check input argument
            if nargin < 1
                connect = false;
            end %if
                            
            % check if we need to connect
            if connect || ...
                    ~isa(localObj.m,'com.mongodb.Mongo') || ...
                    ~isa(localObj.db,'com.mongodb.DB') || ...
                    ~isa(localObj.coll,'com.mongodb.DBCollection')
%                    ( ~isobject(localObj.m) || ~isvalid(localObj.m) ) || ...
%                    ( ~isobject(localObj.db) || ~isvalid(localObj.db) ) || ...
%                    ( ~isobject(localObj.coll) || ~isvalid(localObj.coll) ) 
                % connect to database
                localObj.connect();
            end %if
            % return object
            singleObj = localObj;
        end %function
    end

    methods
        res = connect(obj)
        res = isValidCollection(obj)
        res = isValidConnection(obj)
        res = isValidDatabase(obj)
        res = isValid.m(obj)
        res = find(obj,query)
        res = delete(obj,query)
        res = insert(obj,query)
        res = update(obj,query,values)
    end
    
    methods (Static)
        output = prepQuery(input)
    end %methods static
end

