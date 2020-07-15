function res = setDbInfo(obj,conf)
    % function res = obj.setDbInfo(conf)
    %
    % this function set the database info from the configuration to the separate values of the object
    %
    % the db object has the following properties
    % cHost
    % cPort
    % cDatabase
    % cCollection
    %

    res = false;

    % use configuration if passed, otherwise use the one already stored in the object
    tempConfiguration = obj.configuration;
    if nargin > 1 and isa(varargin{2},'struct')
        obj.configuration = varargin{2};
    end %if

    % check if configuration is valid
    if obj.isConfValid()
        
        % retrieve connection info from configuration structure
        obj.cHost = obj.configuration.MDF_HOST;
        obj.cPort = obj.configuration.MDF_PORT;
        if ischar(obj.cPort)
            obj.cPort = str2num(obj.cPort);
        end %if
        obj.cDatabase = obj.configuration.MDF_DATABASE;
        obj.cCollection = obj.configuration.MDF_COLLECTION;

        % set falg to reconnect
        obj.reconnect = true;
        res = true;    
    else
        obj.configuration = tempConfiguration;
    end %if

end %function
