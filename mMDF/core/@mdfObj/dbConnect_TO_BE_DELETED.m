function res = dbConnect()
    % function res = dbConnect()
    %
    % this function establish the connection to mongodb
    % the connection is stored in a global variable called RF_DB
    %
    % RF_DB has the following structure
    %  .m = mongodb connection object
    %  .db = mongodb database object
    %  .coll = mongodb collection for mdf
  

    % access global variable
    global RF_DB
 
    
    % check if the connection object us instantiated
    if is_empty(RF_DB.m)
        % load java library
	javaaddpath('/data/data1/test/mdf/code/java/mongo-java-driver-3.2.1.jar')
import com.mongodb.*
m = Mongo('localhost',27017)

db = m.getDatabaseNames()
# [mdf, test, local]

db = m.getDB('mdf')

db.getCollectionNames()
# [mdf, system.indexes]

dbcmdf = db.getCollection('mdf')



t1 = dbcmdf.find()
