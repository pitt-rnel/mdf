function res = isValidConnection(obj)
    % function res = obj.isValidConnection()
    %
    % returns true if the mongo connection class is valid
    %

    % check if the mongo database object is instantiated
    res = false;
    try
        if isa(obj.m,'com.mongodb.Mongo')
            temp = obj.m.getDatabaseNames(); 
            res = true;
        end %if
    catch 
        % nothing to do
    end %try/catch

end % function
