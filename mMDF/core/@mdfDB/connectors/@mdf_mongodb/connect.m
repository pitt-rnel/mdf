function res = connect(obj)
    % function res = obj.connect()
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

    % get reference to configuration class
    oc = mdfConf.getInstance();
    
    % force re-instantiation flag
    ri = false;

    % update connection info if needed and set reinstantiation flag
    % host
    temp = oc.getConstant('DB_HOST','value',mdfDB.DEFAULT_HOST); 
    if ~strcmp(obj.host,temp)
        obj.host = temp;
        ri = true;
    end %if
    % port
    temp = str2num(oc.getConstant('DB_PORT','value',mdfDB.DEFAULT_PORT)); 
    if ~isnumeric(obj.port) || isempty(obj.port) || obj.port ~= temp
        obj.port = temp;
        ri = true;
    end %if
    % database
    temp = oc.getConstant('DB_DATABASE','value',mdfDB.DEFAULT_DATABASE); 
    if ~strcmp(obj.database,temp)
        obj.database = temp;
        ri = true;
    end %if
    % collection
    temp = oc.getConstant('DB_COLLECTION','value',mdfDB.DEFAULT_COLLECTION); 
    if ~strcmp(obj.host,temp)
        obj.collection = temp;
        ri = true;
    end %if
 
    % skip instantiation
    si = false;
    % instantiate connector class
    if ( ri || ~isobject(obj.m) || ~isvalid(obj.m) )
        try 
            obj.m = Mongo(obj.host,obj.port);
            ri = true;
        catch
            si = true;
        end %try/catch
    end %if

    % instantiate database class
    if ~si && ri || ( ~isobject(obj.db) || ~isvalid(obj.db) )
        try
            obj.db = obj.m.getDB(obj.database);
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
