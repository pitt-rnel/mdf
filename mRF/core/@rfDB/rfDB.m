classdef (Sealed) rfDB < handle

    properties (Constant)
        Jar =  '../../../java/mongo-java-driver-3.2.1.jar';
        Host = 'localhost';
        Port = 27017;
        Database = 'rf';
        Collection = 'rf';
    end  

    properties
        m = [];
        db = [];
        coll = [];
    end

    methods (Access = private)
        function obj = rfDB
        end
    end
    methods (Static)
        function singleObj = getInstance(connect)
            mlock;
            % use a persistent variable to mantain the instance
            persistent localObj
            % check if the persisten object is actually an object and is
            % valid
            if isempty(localObj) || ~isvalid(localObj)
                % instantiate new object
                localObj = rfDB;
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

