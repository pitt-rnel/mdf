function res = isValidDatabase(obj)
    % function res = obj.isValidDatabase()
    %
    % returns true if the database object is valid
    %

    res = false;
    try
        if isa(obj.db,'com.mongodb.DB')
            temp = obj.db.getCollectionNames();
            res = true;
        end %if
    catch
        % nothing to do
    end %try/catch

end % function
