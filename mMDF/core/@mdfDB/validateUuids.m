function [res, duplicates] = validateRelationships(obj)
    % function [res, duplicates] = obj.validateUuids()
    %
    % check the data collection contains any duplicate uuid
    % Output
    % - res        : (boolean) True if all the relationships are valid, false otherwise
    % - duplicates : (cell) list of the duplicate uuid
    %

    % -----------------------
    % Check if there are any duplicated uuids
    pipeline = { ...
     '{ $project : { "_id" : 0 , "mdf_uuid" : "$mdf_def.mdf_uuid" }}', ...
     '{ $group : { "_id" : "$mdf_uuid", "count" : { $sum : 1 }}}', ...
     '{ $match : { "count" : { $gt : 1 }}}', ...
     '{ $project : { "mdf_uuid" : "$_id", "count" : 1, "_id" : 0}}' };
    
    dupUuids = obj.aggregate(pipeline);

    %
    % prepare results
    res = ( length(dupUuids) > 0);

    if nargout > 1
        duplicates = dupUuids;
    end %if

end %function
