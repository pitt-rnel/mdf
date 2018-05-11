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
        % convert query to basic db object
        query = obj.toBasicDBObject(query)
        % convert values to basic db object
        values = mdf.toJson(values)
        % set the %set parameter in the values
        % this way it updates keeping previous fields
        values = obj.toBasicDBObject(['{ "$set": ' values ' }']);

        % record is in json format (aka string)
        wr = obj.coll.update( ...
            query, ...
            values, ...
            upsert, ...
            false);
        res = 1;
    catch
        % nothing to do
    end %for 
end %function

