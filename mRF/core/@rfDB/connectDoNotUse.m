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


    % check if the mongo database object is instantiated
    inst = false;
    try
        if strcmp(obj.m,'com.mongodb.Mongo')
            res = m.getDatabaseNames(); 
            inst = true;
        end %if
    catch 
        % nothing to do
    end %try/catch

    if ~inst

        % load java library
        javaaddpath('../../../java/mongo-java-driver-3.2.1.jar');
        % import java library and classes
        import com.mongodb.*;
  
        % instantiate database class
        obj.m = Mongo('localhost',27017);

        % initialize or reset db and coll properties
        obj.db = [];
        obj.coll = [];

    end %if

    inst = false;
    try
        if strcmp(obj.db,'com.mongodb.DB')
            res = obj.db.getCollectionNames();
            inst = true;
        end %if
    catch
        % nothing to do
    end %try/catch

    if ~inst
        % select database from mongo object
        obj.db = obj.m.getDB('rf')
    end %if

    inst = false;
    try
        if strcmp(obj.coll,'com.mongodb.DBCollection')
            res = obj.coll.findOne();
            inst = true;
        end %if
    catch

db = m.getDatabaseNames()
# [rf, test, local]

db = m.getDB('rf')

db.getCollectionNames()
# [rf, system.indexes]

dbcrf = db.getCollection('rf')



t1 = dbcrf.find()


      end
