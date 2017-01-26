function outdata = getCollStats(obj)
    % function outdata = obj.getCollStats
    %
    % return which mdf type are present in the collection that we are
    % connected to and how many of each
    %
    % output
    % - outdata (struct): objects type and how many. It is a struct where
    %                     the keys are the type of objects and the value is 
    %                     how many of each type are present in the collection 
    %
    
    % improt correct java object
    import com.mongodb.BasicDBObject
    
    % run map reduce command on collection
    % db.sensory.mapReduce( ...
    %  function() { emit( this.mdf_def.mdf_type, 1 )}, ...
    %  function(key, values) { return Array.sum(values) }, ...
    %  { query: {}, out: "obj_num" } ).find()
    %
    % java object MapReduceOutput
    mrOut = obj.coll.mapReduce( ...
        'function() { emit( this.mdf_def.mdf_type, 1 )}', ...
        'function(key, values) { return Array.sum(values) }', ...
        'obj_num', ...
        BasicDBObject.parse('{}') );
    
    % get db cursor
    mrDBCursor = mrOut.results();
    % get java array
    mrJArrayList = mrDBCursor.toArray();
    % get java mongodb objects
    mrMongoDBObjects = mrJArrayList.toArray();
    
    % initialize output structure
    outdata = struct('mdf_type','','quantity','');
    % loop on each result returned
    for i = 1:length(mrMongoDBObjects)
        % get inidvidual result
        row = mrMongoDBObjects(i);
        % get key and value
        outdata(i).mdf_type = row.get('_id');
        outdata(i).quantity = row.get('value');
    end %for
end %function