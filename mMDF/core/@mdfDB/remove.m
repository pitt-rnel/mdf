function res = remove(obj,query)
    % function res = obj.remove(query)
    %
    % delete all the records matching the query
    % input
    %   query : string, or struct containing the query
    %           if it is a string, it is assumed that is the json rapresentation of the query.
    %           if it is a struct, it is the struct rapresentation of the query
    %
    % output
    %   res = number of the records deleted
    %

    % initialize output
    res = 0;

    % import query object
    import com.mongodb.BasicDBObject

    % prepare write concern object
    wc = com.mongodb.WriteConcern(1);

    try
        % transform struct in a json string
        query = obj.toBasicDBObject(query);
        % record is in json format (aka string)
        wr = obj.coll.remove( ...
            query, ...
            wc);
        res = wr.getN();
    catch
        % nothing to do
        res = -1;
    end %for 
end %function

