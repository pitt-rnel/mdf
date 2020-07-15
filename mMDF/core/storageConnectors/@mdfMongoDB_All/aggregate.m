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
    import java.util.ArrayList;

    % instantiate db list object
    aggrlist = ArrayList();
    
    % loops on all the elements in the pipeline and insert them in the list
    for i = 1:length(pipeline)
        % extract pipeline step
        istep = pipeline{i};
     
        % it is a structure (it supposed to be)
        % we need to convert in BasicDBObject that is the format the mongodb driver unerstand and accept
        ostep = obj.toBsonDocument(istep);
        
        % insert step in list
        aggrlist.add(ostep); 
    end %for

    % runs the aggregation
    % object returned is a container object with all the results
    oaggr = obj.coll.aggregate(aggrlist);    
    
    % get iteratable cursor
    ocur = oaggr.iterator();

    % if we got results, we transform them in structure and we pass it back as a cell array
    res = {};
    % loop until we transfer all the returned objects
    while ocur.hasNext()
        % get next element in list
        ele = ocur.next();
        % convert it to structure throught json
        res{length(res)+1} = mdf.fromJson(char(ele.toJson()));
    end %while
    
end %function
