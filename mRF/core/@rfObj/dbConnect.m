function res = dbConnect()
    % function res = dbConnect()
    %
    % this function establish the connection to mongodb
    % the connection is stored in a global variable called RF_DB
    %
    % RF_DB has the following structure
    %  .m = mongodb connection object
    %  .db = mongodb database object
    %  .coll = mongodb collection for rf
  

    % access global variable
    global RF_DB
 
    
    % check if the connection object us instantiated
    if is_empty(RF_DB.m)
        % load java library
	javaaddpath('/data/data1/test/rf/code/java/mongo-java-driver-3.2.1.jar')
import com.mongodb.*
m = Mongo('localhost',27017)

db = m.getDatabaseNames()
# [rf, test, local]

db = m.getDB('rf')

db.getCollectionNames()
# [rf, system.indexes]

dbcrf = db.getCollection('rf')



t1 = dbcrf.find()
