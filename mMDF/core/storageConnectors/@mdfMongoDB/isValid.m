function res = isValid(obj)
    % function res = obj.isValid()
    %
    % returns true if all the connection ti the database and all the relevant objects are still valid
    %

    res = obj.isValidConnection() && ...
        obj.isValidDatabase() && ...
        obj.isValidCollection();

end %function
