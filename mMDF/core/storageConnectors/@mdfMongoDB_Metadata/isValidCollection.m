function res = isValidCollection(obj)
    % function res = obj.isValidCollection()
    %
    % returns true if the collection object is still valid
    %

    res = false;
    try
        if isa(obj.coll,'com.mongodb.DBCollection')
            temp = obj.coll.findOne();
            res = true;
        end %if
    catch
        % nothing to do
    end %try/catch

end %function
