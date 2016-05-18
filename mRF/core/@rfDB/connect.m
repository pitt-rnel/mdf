function res = connect(obj)
    % function res = obj.connect()
    %
    % this function establish the connection to mongodb
    % the connection is stored in a global variable called RF_DB
    %
    % the db object has the following properties
    %  .m = mongodb connection object
    %  .db = mongodb database object
    %  .coll = mongodb collection for rf

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
    
    % force re-instantiation
    ri = false;
    % skip instantiation
    si = false;
    % instantiate connector class
    if ( ~isobject(obj.m) || ~isvalid(obj.m) )
        try 
            obj.m = Mongo(obj.Host,obj.Port);
            ri = true;
        catch
            si = true;
        end %try/catch
    end %if

    % instantiate database class
    if ~si && ri || ( ~isobject(obj.db) || ~isvalid(obj.db) )
        try
            obj.db = obj.m.getDB(obj.Database);
            ri = true;
        catch
            si = true;
        end %try/catch
    end %if

    % instantiate collection class
    if ~si && ri || ( ~isobject(obj.coll) || ~isvalid(obj.coll) )
        try
            obj.coll = obj.db.getCollection(obj.Collection);
            ri = true;
        catch
            si = true;
        end
        
    end %if

    res = (ri && ~si);
end
