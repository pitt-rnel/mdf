classdef (Sealed) mdf_connector < handle

    properties
        %
        % habitat configuration
        configuration = [];
        %
        % operations available by the connector
        operations = { ...
            "insert", ...
            "update", ...
            "query", ...
            "delete" };
    end

    methods
        function obj = mdf_connector(configuration)
            % constructor
            obj.configuration = configuration;
        end
    end

    methods
        %
        % 
        function res = getOps(obj)
            % function res = obj.getOps()
            %
            res = obj.operations;
        end %function
        %
        % 
        function uuid = getUuid(obj)
            uuid = obj.configuration.uuid;
        end %function

    end

    methods (Abstract)
        res = insert(obj,indata);
        res = update(obj,indata);
        res = query(obj,indata);
        res = delete(obj,indata);
    end
    
end

