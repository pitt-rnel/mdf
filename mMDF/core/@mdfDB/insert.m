function res = insert(obj,records)
    % function res = obj.insert(records)
    %
    % insert records in database back end
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

    % import query object
    import com.mongodb.BasicDBObject

    % transform input in cell if needed
    if ~isa(records,'cell')
        records = {records};
    end %if

    % prepare write concern object
    wc = com.mongodb.WriteConcern(1);

    % loop on all the records to be inserted
    for i = 1:length(records)
        % extract record to be inserted in db
        record = records{i};
        try
            % converts it to a basic db object
            record = obj.toBasicDBObject(record);
            % record is ready to be inserted
            ir = obj.coll.insert( ...
                record, ...
                wc);
            res = res + 1;
        catch
            % nothing to do
        end
    end %for 
end %function

