function res = connect(obj,varargin)
    % function res = obj.connect(conf)
    %
    % this function establish the connection to mongodb 
    % for the database containing only metadata and object definitions
    %
    % the db object has the following properties
    % oMongo' = []
    % oDatabase = []
    % oCollection = []
    %
    %
    % we assume that the java library is already onthe matlab javapath
    % check the documentation on how to add java path in matlab
    %

    % import java library and classes
    % at start up time, this appear to not work
    import com.mongodb.*;

    % use configuration if passed, otherwise use the one already stored in the object
    if nargin > 1 and isa(varargin{2},'struct')
        obj.setDbInfo(varargin{2});
    end %if

    % check if configuration is valid
    if ~obj.isConfValid()
        
        % skip instantiation
        si = false;
        % instantiate connector class
        if ( obj.reconnect || ~isobject(obj.oMongo) || ~isvalid(obj.oMongo) )
            try 
                obj.oMongo = MongoClient(obj.cHost,obj.cPort);
                obj.reconnect = true;
            catch
                si = true;
            end %try/catch
        end %if

        % instantiate database class
        if ~si && obj.reconnect || ( ~isobject(obj.oDatabase) || ~isvalid(obj.oDatabase) )
            try
                obj.oDatabase = obj.oMongo.getDatabase(obj.cDatabase);
                obj.reconnect = true;
            catch
                si = true;
            end %try/catch
        end %if

        % instantiate collection class
        if ~si && obj.reconnect || ( ~isobject(obj.oCollection) || ~isvalid(obj.oCollection) )
            try
                obj.oCollection = obj.oDatabase.getCollection(obj.cCollection);
                obj.reconnect = true;
            catch
                si = true;
            end
        end %if
    end %if

    % returns true if everything went according to plan
    res = (obj.reconnect && ~si);
    obj.reconnect = false;

end % function
