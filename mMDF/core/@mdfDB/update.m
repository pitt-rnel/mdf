function res = update(obj,query,values,upsert)
    % function res = obj.update(query,values,upsert)
    %
    % update all the records matching the query with the passed values
    % input
    %   query  : string, or struct containing the query
    %            if it is a string, it is assumed that is the json rapresentation of the query.
    %            if it is a struct, it is the struct representation of the query
    %   values : string or structure conatining the values to be set
    %            same as for query
    %   upsert : boolean true or false. If set to true, it will create the document, if not found
    %
    % output
    %   res = 1 if the record has been update, 0 if not
    %

    % initialize output
    res = 0;

    % import query object
    import com.mongodb.BasicDBObject
   
    % check if upsert is set or not
    if nargin > 2 && upsert == true
	upsert = true;
    else
        upsert = false;
    end %if

    try
        % check if query is a struct
        if isa(query,'struct')
            % transform struct in a json string
            query = mdf.toJson(query);
        end %if
        % check if values is a struct
        if isa(values,'struct')
            % transform struct in a json string
            values = mdf.toJson(values);
        end %if
        % set the %set parameter in the values
        % this way it updates keeping previous fields
        values = ['{ "$set": ' values ' }'];

        % record is in json format (aka string)
        wr = obj.coll.update( ...
            BasicDBObject.parse(query), ...
            BasicDBObject.parse(values), ...
            upsert, ...
            false);
        res = 1;
    catch
        % nothing to do
    end %for 
end %function
