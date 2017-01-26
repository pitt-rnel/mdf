function [data] = getCollectionStats(obj,collection)
    % function [data] = obj.getCollectionStats(collection)
    %
    % return for te collection open the object types and how many are in
    % the collection
    % 
    % Input:
    %  - colleciton : (string) collection that we want to do statistic on
    %                 NOT USED at the moment.
    %
    % Output
    %  - data  : (array of struct) list of structs reporting objct type and
    %            their number in the database
    %
    % Source of inspiration: 
    % https://github.com/HanOostdijk/matlab_mongodb/blob/master/mm_example_7.m

    % improt correct java object
    import com.mongodb.BasicDBObject
    import com.mongodb.BasicDBList
    import com.mongodb.MapReduceCommand
    
    % retrieve mdf db object
    odb = mdfDB.getInstance();

    % check input arguments
    if nargin > 1
        % here there will be the validation of the collection
    end %if

    % result collection name
    sResColl = ['coll_stat_' datestr(now,'yyyymmddHHMMSSFFF')];   

    % mapReduce statement from mongo console
    % db.runCommand(
    %  {
    %   mapReduce: 'flahr', 
    %   map: function() { 
    %     emit( this.mdf_def.mdf_type, 1 )
    %   },
    %   reduce: function(key, values) {
    %     return Array.sum(values) 
    %   },
    %   out: 'coll_stats_1'
    %  }
    % )
    %

    % unfortunately java driver does not allow us to run a map reduce from
    % a runCommand function (See sensoryQuery4_alpha1)
    %
    % create string with mapper function
    mapper = [ ...
       'function() {' ...
        'emit( this.mdf_def.mdf_type, 1 )' ...
       '}'...
      ] ;

    % reducer function
    reducer = [ ...
      'function(key, values) {' ...
       'return Array.sum(values) ' ...
      '}' ...
      ] ;
  
    % query portion as a string
    sQuery1 = ['{}'];
    
    % query portion as DBObject
    oQuery1 = BasicDBObject.parse(sQuery1);
    
    % replace content of previous one if any
	REPLACE = javaMethod('valueOf', ...
        'com.mongodb.MapReduceCommand$OutputType', ...
        'REPLACE');

	% get db object
    odb = mdfDB.getInstance();
    
    % build the map reduce command
    % 1) input collection
    % 2) map - function
    % 3) reduce - function
    % 4) name of output collection
    % 5) overwrite (don't merge) output collection            
    % 6) input query (none so all documents)   
    mpc = MapReduceCommand( ...
        odb.coll, ...
        mapper, ...
        reducer, ...
        sResColl, ...
        REPLACE, ...
        oQuery1);
    
	% run map reduce command and get output query
    oResColl = odb.coll.mapReduce(mpc).getOutputCollection() ;

    %
    % query result collection using an aggregation
    % string command
    sCommand2 = [ '{}' ];
  
    % convert command string to basicDBObject
    oCommand2 = BasicDBObject.parse(sCommand2);

    % run query on result collection
    cRes2 = oResColl.find( oCommand2 );

    % get values from the results
    % object returned is a java.util.HashMap$Values
    oTemp1 = cRes2.values;
    % converts it to an array
    % object returned is an array of java.lang.Object
    oTemp2 = oTemp1.toArray();
    % the results are in the first element of the array
    % select first element and converts it to a cell array
    % object returned is a cell array of com.mongodb.BasicDBList
    oTemp3 = oTemp2(1).toArray.cell;

    % return an array of structs with the following keys
    data = struct( ...
        'mdf_type', cellfun(@(x) x.get('_id'), oTemp3, 'UniformOutput', 0), ...
        'quantity', cellfun(@(x) x.get('value'), oTemp3, 'UniformOutput', 0) ...
    );
    
    %
    % drop temporary collection
    %
    % drop collection
    oResColl.drop();

end %function
