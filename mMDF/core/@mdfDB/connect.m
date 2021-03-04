function res = connect(obj,conf)
    % function res = obj.connect(conf)
    %
    % this function establish the connection to mongodb
    % the connection is stored in a global variable called RF_DB
    %
    % the db object has the following properties
    %  .m = mongodb connection object
    %  .db = mongodb database object
    %  .coll = mongodb collection for mdf
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

    % force re-instantiation flag
    ri = false;

    % check input and that it is of the correct type
    if ~obj.isConfSet()
        
        if nargin == 2 && ~isstruct(conf)
            % get reference to configuration class
            oc = mdfConf.getInstance();
    
            % retrieve connection info from configuratin class
            DB_HOST = oc.getConstant( 'DB.HOST','value', oc.getConstant('DB_HOST','value',mdfDB.DEFAULT_HOST));
            DB_PORT = oc.getConstant( 'DB.PORT','value', oc.getConstant('DB_PORT','value',mdfDB.DEFAULT_PORT));
            if ischar(DB_PORT)
                DB_PORT = str2num(DB_PORT);
            end %if
            DB_DATABASE = oc.getConstant( 'DB.DATABASE','value', oc.getConstant('DB_DATABASE','value',mdfDB.DEFAULT_DATABASE));
            DB_COLLECTION = oc.getConstant( 'DB.COLLECTION','value', oc.getConstant('DB_COLLECTION','value',mdfDB.DEFAULT_COLLECTION));
          
            % setup connection structure
            conf = struct( ...
                'host'      , DB_HOST, ...
                'port'      , DB_PORT, ...
                'database'  , DB_DATABASE, ...
                'collection', DB_COLLECTION ...
            );
        else
            conf = [];
        end %if
    

        % update connection info if needed and set reinstantiation flag
        % host
        if isstruct(conf) && isfield(conf,'host') && ~strcmp(obj.host,conf.host)
            obj.host = conf.host;
            ri = true;
        end %if
        % port
        if isstruct(conf) && isfield(conf,'port') && (isempty(obj.port) || obj.port ~= conf.port)
            obj.port = conf.port;
            ri = true;
        end %if
        % database
        if isstruct(conf) && isfield(conf,'database') && ~strcmp(obj.database,conf.database)
            obj.database = conf.database;
            ri = true;
        end %if
        % collection
        if isstruct(conf) && isfield(conf,'collection') && ~strcmp(obj.host,conf.collection)
            obj.collection = conf.collection;
            ri = true;
        end %if
    end %if
    
    % skip instantiation
    si = false;
    % instantiate connector class
    if ( ri || ~isobject(obj.m) || ~isvalid(obj.m) )
        try 
            obj.m = MongoClient(obj.host,obj.port);
            ri = true;
        catch
            si = true;
        end %try/catch
    end %if

    % instantiate database class
    if ~si && ri || ( ~isobject(obj.db) || ~isvalid(obj.db) )
        try
            obj.db = obj.m.getDatabase(obj.database);
            ri = true;
        catch
            si = true;
        end %try/catch
    end %if

    % instantiate collection class
    if ~si && ri || ( ~isobject(obj.coll) || ~isvalid(obj.coll) )
        try
            obj.coll = obj.db.getCollection(obj.collection);
            ri = true;
        catch
            si = true;
        end
        
    end %if

    res = (ri && ~si);
end
