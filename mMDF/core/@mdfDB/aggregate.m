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

    % prepare options (for future version of the API)
    % options = BasicDBObject.parse('{ cursor: {} }');
    
    % runs the aggregation
    % object returned is a container object with all the results
    oaggr = obj.coll.aggregate(aggrlist);

    % check if this version of matlab has json functions builtin
    jsonapi = (exist('jsondecode') == 5);
   
    % prepare output array
    % oaggr.results is a java json string with all the results
    % first we convert it to a matlab char,
    % than from json to cell array 
    % and finally we go from cell to matrix
    if jsonapi
        res = cell2mat(jsondecode(char(oaggr.results)));
    else
        res = cell2mat(loadjson(char(oaggr.results)));
    end %if

end %function
