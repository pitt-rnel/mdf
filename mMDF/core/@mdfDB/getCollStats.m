function outdata = getCollStats(obj,varargin)
    % function outdata = obj.getCollStats
    %
    % return which mdf type are present in the collection that we are
    % connected to and how many of each
    %
    % input
    % - table  (boolean): should the results be printed in tabular form
    %                     Default: false
    %
    % output
    % - outdata (struct): objects type and how many. It is a struct where
    %                     the keys are the type of objects and the value is 
    %                     how many of each type are present in the collection 
    %
    
    % check if user specified table argument
    table = false;
    if nargin >= 2
        table = varargin{1};
    end %if
    
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
    
    % drop temp collection
    tempcoll = obj.db.getCollection('obj_num');
    tempcoll.drop();
    
    if table
        format = '%20s %10';
        disp(sprintf([format,'s'],'MDF object type','Quantity'));
        disp(sprintf([format,'s'],'--------------------','----------'));
        arrayfun(@(item) disp(sprintf([format, 'd'],item.mdf_type,item.quantity)),outdata);
    end %if
end %function