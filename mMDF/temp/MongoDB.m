%
% https://github.com/asangpet/tactic/blob/master/src/main/java/edu/cmu/tactic/services/ResponseDataService.java
%


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
# t1 =
#  DBCursor{collection=DBCollection{database=DB{name='rf'}, name='rf'}, find=FindOptions{, batchSize=0, limit=0, modifiers=null, projection=null, maxTimeMS=0, skip=0, sort=null, cursorType=NonTailable, noCursorTimeout=false, oplogReplay=false, partial=false}}

class(t1)
# ans = com.mongodb.DBCursor

t1.count()
# ans = 1

t2 = t1.iterator()
# t2 =
#  DBCursor{collection=DBCollection{database=DB{name='rf'}, name='rf'}, find=FindOptions{, batchSize=0, limit=0, modifiers=null, projection=null, maxTimeMS=0, skip=0, sort=null, cursorType=NonTailable, noCursorTimeout=false, oplogReplay=false, partial=false}}

t2.hasNext()
# ans = 1

t3 = t2.next()
# t3 =
#  { "_id" : { "$oid" : "56a9084428eb4f474d02335c"} , "rf_version" : 1.0 , "rf_def" : { "rf_type" : "subject" , "rf_uuid" : "10d22166-da50-4e18-a6e0-a647590fc876" , "rf_files" : { "rf_data" : "sbj_29/sub_29.h5" , "rf_metadata" : "sbj_29/sbj_29.yml"} , "rf_data" : { "rf_fields" : [ ]} , "rf_metadata" : { "id" : 29.0 , "name" : "Flahr" , "USDA" : "13CGP1" , "nicknames" : [ "Sylvester"] , "birthday" : "2013-05-07" , "arrival" : "2014-03-04" , "source" : "Liberty Lab" , "spieces" : "cat" , "sex" : "neutered male" , "coat" : "black" , "end" : "2014-12-04"} , "rf_children" : { "rf_fields" : [ "exp"] , "rf_type" : [ "experiment"] , "exp" : { "rf_uuid" : "db88d8a9-6a59-42b0-9b71-6d11ef620368" , "rf_file" : "sbj-29/experiment/sbj_29.exp.h5" , "rf_type" : "experiment'"} , "rf_parents" : { "rf_uuid" : [ ] , "rf_file" : [ ] , "rf_type" : [ ]}}}}

t2.hasNext()
# ans = 0

