function res = mapReduce(obj,mapFunction,reduceFunction)
    % function res = obj.mapReduce(mapFunction,reduceFunction)
    %
    % search the database and aggregate the data according to pipeline passed
    % 
    % input
    %  - map: (string) map function
    %  - reduce: (string) reduce function
    %              please refer to https://docs.mongodb.com/manual/mapreduce/
    %
    %
    

    % runs the aggregation
    % object returned is a container object with all the results
    omr = obj.coll.mapReduce(mapFunction,reduceFunction);    
    
    % get iteratable cursor
    ocur = omr.iterator();

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
