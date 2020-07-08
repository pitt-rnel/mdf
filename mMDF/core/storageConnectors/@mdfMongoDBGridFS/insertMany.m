function res = insertMany(obj,records)
    % function res = obj.insertMany(records)
    %
    % insert records in database back end using insertMany
    % input
    %   records : single string, or single struct or cell array of string or structs
    %             if it is a single string, it is assumed that is the json rapresentation of the record.
    %             if it is a single struct, it is the struct rapresnetation of the single record
    %             if it is a cell array, each element can be any of the above.
    %
    % output
    %   res = number of the records inserted
    %

    % initialize output
    res = 0;

    % import java array list
    import java.util.ArrayList;

    % transform input in cell if needed
    if ~isa(records,'cell')
        records = {records};
    end %if

    % initialize list
    recordList = ArrayList();
    
    % loop on all the records to be inserted
    for i = 1:length(records)
        % extract record to be inserted in db
        record = records{i};
        % converts it to a basic db object
        record = obj.toBsonDocument(record);
        % append to list
        recordList.add(record);
    end %for
        
    % execute insert
    try
        % record is ready to be inserted
        obj.coll.insertMany(recordList);
        res = 1;
    catch
    	% nothing to do
        res = -1;
    end
end %function

