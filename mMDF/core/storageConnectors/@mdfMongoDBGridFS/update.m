function res = update(obj,query,values,upsert)
    % function res = obj.update(query,values,upsert)
    %
    % update all the records matching the query with the passed values
    % input
    %   query  : string, or struct containing the query
    %            if it is a string, it is assumed that is the json rapresentation of the query.
    %            if it is a struct, it is the struct representation of the query
    %   values : string or structure contining the values to be set
    %            same as for query
    %   upsert : boolean true or false. If set to true, it will create the document, if not found
    %
    % output
    %   res = 1 if the record has been update, 0 if not
    %

    % initialize output
    res = 0;
    
    % import needed java classes
    import com.mongodb.client.model.UpdateOptions;
  
    % check if upsert is set or not
    options = UpdateOptions;
    options.upsert(false);
    if nargin > 2 && upsert == true
	    options.upsert(true);
    end %if

    try
        % convert query to basic db object
        query = obj.toBsonDocument(query);
        % convert values to basic db object
        values = mdf.toJson(values);
        % set the %set parameter in the values
        % this way it updates keeping previous fields
        values = obj.toBsonDocument(['{ "$set": ' values ' }']);

        % record is in json format (aka string)
        wr = obj.coll.updateMany( ...
            query, ...
            values, ...
            options);
        res = 1;
    catch
        % nothing to do
        res = -1;
    end %for 
end %function

