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
        % connect to the database 
        res = connect(obj)
        % check if the collection handle is valid
        res = isValidCollection(obj)
        % check if the connection to the mongo instance is valid
        res = isValidConnection(obj)
        % check if the database handle is valid
        res = isValidDatabase(obj)
        % check if connection, database and collection handles are valid
        res = isValid.m(obj)
        % search and return onbject founds 
        res = find(obj,query,projection,sort)
        % delete objects according to query. placemark for remove
        res = delete(obj,query)
        % remove objects according to query
        res = remove(obj,query)
        % ??
        res = save(obj,query)
        % we should combine the next two with an upsert
        % insert records in database
        res = insert(obj,query)
        % update record in database
        res = update(obj,query,values)
        % return object types in this ecosystem and how many of them
        res = getCollStats(obj)
        % return list of methods available
        % MN: find if we can place it in the abstract class
        res = getMethods(obj)
    end
    
    methods (Static)
        output = prepQuery(input)
    end %methods static
end

