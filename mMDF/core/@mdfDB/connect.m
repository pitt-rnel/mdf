function res = connect(obj,conf)
    % function res = obj.connect(conf)
    %
    % this function establish the connection to mongodb
    % the connection is stored in a global variable called RF_DB
    %
    % the db object has the following properties
    % main = struct( ...
    %        'mongo', [], ...
    %        'database', [], ...
    %        'collection', []...
    %    );
    % data = struct( ...
    %        'mongo', [], ...
    %        'database', [], ...
    %        'bucket', [] ...
    %    );
    %

    %% get current folder
    %[cf,~,~] = fileparts(mfilename('fullpath'));
    %% build full path to library
    %fp = fullfile(cf,obj.Jar);

    % check if it is already in path
    %if not(ismember(fp, javaclasspath ('-dynamic')))
    %    % load java library
    %    javaaddpath(fp);
    %end %if

    % import java library and classes
    % at start up time, this appear to not work
    import com.mongodb.*;

    % get reference to configuration class
    oc = mdfConf.getInstance();

    % force re-instantiation flag
    ri = false;

    % check input and that it is of the correct type
    if ~obj.isConfSet()
        
        if nargin == 2 && ~isstruct(conf)
    
            % retrieve connection info from configuratin class
            % this is the main database: object def and metadata 
            % (also data if DATA is set to MONGODB)
            DB_HOST = oc.getConstant( ...
                'DB.HOST','value', ...
                oc.getConstant('DB_HOST','value',mdfDB.DEFAULT_HOST));
            DB_PORT = oc.getConstant( ...
                'DB.PORT','value', ...
                oc.getConstant('DB_PORT','value',mdfDB.DEFAULT_PORT));
            if ischar(DB_PORT)
                DB_PORT = str2num(DB_PORT);
            end %if
            DB_DATABASE = oc.getConstant( ...
                'DB.DATABASE','value', ...
                oc.getConstant('DB_DATABASE','value',mdfDB.DEFAULT_DATABASE));
            DB_COLLECTION = oc.getConstant( ...
                'DB.COLLECTION','value', ...
                oc.getConstant('DB_COLLECTION','value',mdfDB.DEFAULT_COLLECTION));
            %
            % this is for mongodb gridfs if DATA is set to MONGODB_GRIDFS
            GRIDFS_HOST = oc.getConstant( ...
                'GRIDFS.HOST','value', [] );
            GRIDFS_PORT = oc.getConstant( ...
                'GRIDFS.PORT','value', [] );
            if ischar(GRIDFS_PORT)
                GRIDFS_PORT = str2num(GRIDFS_PORT);
            end %if
            GRIDFS_DATABASE = oc.getConstant( ...
                'GRIDFS.DATABASE','value', [] );
            GRIDFS_BUCKET = oc.getConstant( ...
                'GRIDFS.BUCKET','value', [] );
          
            
            % setup connection structure
            conf = struct( ...
                'db_host'      , DB_HOST, ...
                'db_port'      , DB_PORT, ...
                'db_database'  , DB_DATABASE, ...
                'db_collection', DB_COLLECTION, ...
                'gridfs_host'      , GRIDFS_HOST, ...
                'gridfs_port'      , GRIDFS_PORT, ...
                'gridfs_database'  , GRIDFS_DATABASE, ...
                'gridfs_bucket'    , GRIDFS_COLLECTION ...                
            );
        else
            conf = [];
        end %if
    

        % update connection info if needed and set reinstantiation flag
        % host
        % main database
        if isstruct(conf) && isfield(conf,'db_host') && ~strcmp(obj.host,conf.host)
            obj.host = conf.host;
            ri = true;
        end %if
        % port
        if isstruct(conf) && isfield(conf,'db_port') && (isempty(obj.port) || obj.port ~= conf.port)
            obj.port = conf.port;
            ri = true;
        end %if
        % database
        if isstruct(conf) && isfield(conf,'db_database') && ~strcmp(obj.database,conf.database)
            obj.database = conf.database;
            ri = true;
        end %if
        % collection
        if isstruct(conf) && isfield(conf,'db_collection') && ~strcmp(obj.collection,conf.collection)
            obj.collection = conf.collection;
            ri = true;
        end %if
        %
        % grid fs if needed
        % check if the data is on gridfs
        if oc.isCollectionData('MONGODB_GRIDFS')
            % host
            if isstruct(conf) && isfield(conf,'gridfs_host') && ~strcmp(obj.gridfs_host,conf.gridfs_host)
                obj.gridfs_host = conf.gridfs_host;
                ri = true;
            end %if
            % port
            if isstruct(conf) && isfield(conf,'gridfs_port') && (isempty(obj.gridfs_port) || obj.gridfs_port ~= conf.gridfs_port)
                obj.gridfs_port = conf.gridfs_port;
                ri = true;
            end %if
            % database
            if isstruct(conf) && isfield(conf,'gridfs_database') && ~strcmp(obj.gridfs_database,conf.gridfs_database)
                obj.gridfs_database = conf.gridfs_database;
                ri = true;
            end %if
            % collection
            if isstruct(conf) && isfield(conf,'gridfs_bucket') && ~strcmp(obj.gridfs_bucket,conf.gridfs_bucket)
                obj.gridfs_bucket = conf.gridfs_bucket;
                ri = true;
            end %if
        end %if
    end %if
    
    % skip instantiation
    si = false;
    % instantiate connector class
    if ( ri || ~isobject(obj.main.mongo) || ~isvalid(obj.main.mongo) )
        try 
            obj.main.mongo = MongoClient(obj.host,obj.port);
            ri = true;
        catch
            si = true;
        end %try/catch
    end %if

    % instantiate database class
    if ~si && ri || ( ~isobject(obj.main.database) || ~isvalid(obj.main.dabase) )
        try
            obj.main.database = obj.main.mongo.getDatabase(obj.database);
            ri = true;
        catch
            si = true;
        end %try/catch
    end %if

    % instantiate collection class
    if ~si && ri || ( ~isobject(obj.main.collection) || ~isvalid(obj.main.collection) )
        try
            obj.main.collection = obj.main.database.getCollection(obj.collection);
            ri = true;
        catch
            si = true;
        end
        
    end %if
    
    % check if the data is on gridfs
    if oc.isCollectionData('MONGODB_GRIDFS')
        % this data collection saves data in mongodb grifs
        %
        % instantiate connection to gridfs collection
        
        % instantiate connector class
        if ( ri || ~isobject(obj.data.mongo) || ~isvalid(obj.data.mongo) )
            try 
                obj.data.mongo = MongoClient(obj.gridfs_host,obj.gridfs_port);
                ri = true;
            catch
                si = true;
            end %try/catch
        end %if

        % instantiate database class
        if ~si && ri || ( ~isobject(obj.data.database) || ~isvalid(obj.data.database) )
            try
                obj.data.database = obj.data.mongo.getDatabase(obj.gridfs_database);
                ri = true;
            catch
                si = true;
            end %try/catch
        end %if

        % instantiate collection class
        if ~si && ri || ( ~isobject(obj.data.bucket) || ~isvalid(obj.data.bucket) )
            try
                obj.data.bucket = GridFSBuckets.create( ...
                    obj.data.database, ...
                    obj.gridfs_bucket);
                ri = true;
            catch
                si = true;
            end
        
        end %if
        
    end %if

    res = (ri && ~si);
end
