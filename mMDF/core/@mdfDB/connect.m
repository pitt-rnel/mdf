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

    % get current folder
    [cf,~,~] = fileparts(mfilename('fullpath'));
    % build full path to library
    fp = fullfile(cf,obj.Jar);

    % check if it is already in path
    if not(ismember(fp, javaclasspath ('-dynamic')))
        % load java library
        javaaddpath(fp);
    end %if

    % import java library and classes
    % at start up time, this appear to not work
    import com.mongodb.*;

    % force re-instantiation flag
    ri = false;

    % check input and that it is of the correct type
    if ~obj.isConfSet()
        
        if nargin == 1 && ~isstruct(conf)
            % get reference to configuration class
            oc = mdfConf.getInstance();
    
            conf = struct( ...
                'host', oc.getConstant('DB_HOST','value',mdfDB.DEFAULT_HOST), ...
                'port', str2num(oc.getConstant('DB_PORT','value',mdfDB.DEFAULT_PORT)), ...
                'database', oc.getConstant('DB_DATABASE','value',mdfDB.DEFAULT_DATABASE), ...
                'collection', oc.getConstant('DB_COLLECTION','value',mdfDB.DEFAULT_COLLECTION) ...
            );
        else
            conf = [];
        end %if
    

        % update connection info if needed and set reinstantiation flag
        % host
        if ~strcmp(obj.host,conf.host)
            obj.host = conf.host;
            ri = true;
        end %if
        % port
        if ~isnumeric(obj.port) || isempty(obj.port) || obj.port ~= conf.port
            obj.port = conf.port;
            ri = true;
        end %if
        % database
        if ~strcmp(obj.database,conf.database)
            obj.database = conf.database;
            ri = true;
        end %if
        % collection
        if ~strcmp(obj.host,conf.collection)
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
