function res = aggregate(obj,pipeline)
    % function res = obj.aggregate(pipeline)
    %
    % search the database and aggregate the data according to pipeline passed
    % 
    % input
    %  - pipeline: (cell) list of the aggregation steps
    %              each item is one step of the aggregation operation
    %              please refer to https://docs.mongodb.com/manual/aggregation/
    %
    %
    

    % import needed mongodb java object
    import com.mongodb.BasicDBObject
    import com.mongodb.BasicDBList

    % instantiate db list object
    aggrlist = BasicDBList();
    
    % loops on all the elements in the pipeline and insert them in the list
    for i = 1:length(pipeline)
        % extract pipeline step
        istep = pipeline{i};
     
        % it is a structure (it supposed to be)
        % we need to convert in BasicDBObject that is the format the mongodb driver unerstand and accept
        ostep = obj.toBasicDBObject(istep);
        
        % insert step in list
        aggrlist.add(ostep); 
    end %for

    % prepare options (for future version of the API)
    % options = BasicDBObject.parse('{ cursor: {} }');
    
    % runs the aggregation
    % object returned is a container object with all the results
    oaggr = obj.coll.aggregate(aggrlist);

    % prepare output array
    % oaggr.results is a java json string with all the results
    % first we convert it to a matlab char,
    % than from json to cell array 
    % and finally we go from cell to matrix
    %
    % check with configuration if json library is native or not
    res = cell2mat(mdf.fromJson(char(oaggr.results)));
    
end %function
