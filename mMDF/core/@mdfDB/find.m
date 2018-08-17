function res = find(obj,query,projection,sort)
    % function res = obj.find(query,projection,sort)
    %
    % search the database with the query passed as an argument
    % 
    % input
    %  - query: (struct)
    %           matlab struct with all the conditions for the find
    %           key is the metadata key, value is is going to be tested
    %           toward the value in db for equality
    %           (string)
    %           string with javacript query according to mongodb syntax
    %  - projection: 
    %           (struct)
    %           matlab struct with all the fields to be selected (1) or
    %           excluded (0). Please refer to mongodb query projections for
    %           more info
    %           (string)
    %           string with the correct javascript syntax of the mongodb
    %           projection
    %  - sort:
    %           (struct)
    %           matlab struct that has as keys the fields to be sorted by
    %           and has values the direction: 1 for ascending, 2 for
    %           descending
    %           (string)
    %           string with the correct javascript syntax fo the mongodb
    %           sorting statement
    %
    

    % first check if we need to convert query to BasicDBObject
    iquery = obj.toBsonDocument('{}');
    if nargin > 1 && ~isempty(query)
        % we got a query
        iquery = obj.toBsonDocument(query);
    end %if
    
    % initialize projection flag
    fproj = false;
    if nargin > 2 && ~isempty(projection)
        % we got a projection too
        iproj = obj.toBsonDocument(projection)
        fproj = true;
    end %if

    % initialize sorting flag
    fsort = false;
    if nargin > 3 && ~isempty(sort)
        % we got the sorting 
        isort = obj.toBsonDocument(sort)
        fsort = true;
    end %if        
    
    % runs the query and gets a java FindItarable object
	ires = obj.coll.find(iquery);
    
    % create the projection if needed
    if fproj
        % we need to run the query and returns only some fields indicated
        % by the projection
        ires = ires.projection(iproj);
    end %if
    
    % check if we need to sort
    if fsort
        % sort ires object
        ires = ires.sort(isort);
    end %if
    
    % get iteratable cursor
    icur = ires.iterator();

    % if we got results, we transform them in structure and we pass it back as a cell array
    res = {};
    % loop until we have items in the collection
    while icur.hasNext()
        % get next element in list
        ele = icur.next();
        % convert it to structure throught json
        res{length(res)+1} = rmfield(mdf.fromJson(char(ele.toJson())),'x_id');
    end %while

end %function
