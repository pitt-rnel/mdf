function ri = setDbUri(obj,conf)
    % function ri = obj.setDbUri(conf)
    %
    % set connection configuration
    % output
    % - ri = (boolean) true if anything changed in the configuration
    %         false if the configuration has not changed
    
    % update connection info if needed and set reinstantiation flag
	% host
    if ~strcmp(obj.host,conf.host)
        obj.host = conf.host;
        ri = true;
    end %if
    % port
    if ~isnumeric(obj.port) || isempty(obj.port) || obj.port ~= conf.port
        obj.port = conf.port;
        ri = true;
    end %if
    % database
    if ~strcmp(obj.database,conf.database)
        obj.database = conf.database;
        ri = true;
    end %if
    % collection
    if ~strcmp(obj.host,conf.collection)
        obj.collection = conf.collection;
        ri = true;
    end %if
end %function
