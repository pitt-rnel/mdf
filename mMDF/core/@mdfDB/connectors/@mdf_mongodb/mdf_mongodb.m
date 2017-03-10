classdef (Sealed) mdf_mongodb < mdf_connector

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

    methods
        function obj = mdf_mongodb(conf)
            % class constructor
            %
            % save configuration
            obj.configuration = conf
            %
            % establish connection to the database 
            % if required 
            % check if we need to connect
            if isfield(conf,'connect') && ...
                    conf.connect 
                % call the connect function
                obj.connect();
            end %if
        end %function constructor
    end

    methods
        res = connect(obj)
        res = isValidCollection(obj)
        res = isValidConnection(obj)
        res = isValidDatabase(obj)
        res = isValid.m(obj)
        res = find(obj,query,projection,sort)
        res = delete(obj,query)
        res = save(obj,query)
        res = insert(obj,query)
        res = update(obj,query,values)
        res = getCollStats(obj)
        res = getMethods(obj)
    end
    
    methods (Static)
        output = prepQuery(input)
    end %methods static
end

