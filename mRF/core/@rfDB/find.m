function res = find(obj,query)
    % function res = obj.find(query)
    %
    % search the database with the query passed as an argument
    % 
    % input
    %  - query: structure with all the conditions according to mongodb syntax

    % import query object
    import com.mongodb.BasicDBObject

    % first check if we need to convert query to BasicDBObject
    iquery = BasicDBObject();
    if nargin > 1
      % we got a query
      % it is a structure (it supposed to be)
      % we need to convert in BasicDBObject that is the format the mongodb driver unerstand and accept
      switch class(query)
          case {'struct'}
              iquery = BasicDBObject.parse(savejson('',query));
          case {'char'}
              iquery = BasicDBObject.parse(query);
      end %switch
    end %if

    % runs the query and gets a java collection with iterator
    ires = obj.coll.find(iquery);

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
