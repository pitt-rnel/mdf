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
        switch class(istep)
            case {'struct'}
                ostep = BasicDBObject.parse(savejson('',istep));
            case {'char'}
                ostep = BasicDBObject.parse(istep);
            otherwise
                throw( ...
                    MException( ...
                        'mdfDB:aggregate', ...
                        'Invalid pipeline step'));
        end %switch
        % insert step in list
        aggrlist.add(ostep); 
    end %for
    
    
    % runs the aggregation
    oaggr = obj.coll.aggregate(aggrlist);
    
    % if we got results, we transform them in structure and we pass it back as a cell array
    res = {};
    % loop until we have items in the collection
    while ires.hasNext()
        % get next element in list
        ele = ires.next();
        % convert it to structure throught json
        res{length(res)+1} = loadjson(char(ele.toJson()));
    end %while

end %function
