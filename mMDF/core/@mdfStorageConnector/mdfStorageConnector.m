classdef (Abstract) mdfStorageConnector < handle

    properties
        %
        % habitat configuration
        configuration = [];
        %
        % operations available by the connector
        operations = struct( ...
            'connect'    , false, ... 
            'find'       , false, ...
            'load'       , false, ...
            'update'     , false, ...
            'remove'     , false, ...
            'isConfValid', false, ...
            'isConnected', false  ...
        );
    end

    methods
        function obj = mdfStorageConnector(configuration)
            % constructor
            obj.configuration = configuration;
        end
    end

    methods
        %
        % 
        function res = getOperations(obj)
            % function res = obj.getOperations()
            %
            res = obj.operations;
        end %function
        %
        % 
        function uuid = getUuid(obj)
            uuid = obj.configuration.uuid;
        end %function

    end

    methods (Abstract,Static)
        %
        % return what is the connector string for the connector
        % it has to be a unique string that matches the class
        res = getCS();
    end

    methods (Abstract)
        res = connect(obj,varargin);
        res = find(obj,varargin);
        res = load(obj,varargin);
        res = update(obj,varargin);
        res = remove(obj,varargin);
        res = isConfValid(obj);
        res = isConnected(obj);
    end %method

    methods
        function res = isConfSet(obj)
            res = ~isempty(obj.configuration) && isa(obj.configuration,'struct');
        end %function

        function value = get.configuration(obj)
            value = obj.configuration;
        end %getter
        function set.configuration(obj,value)
            obj.configuration = value;
        end %setter
    end
    
end

