classdef (Sealed) mdf_connector < handle

    properties
        % sort query run weight
        % it is the number used when you want to order the habitats
        % to run a query on all of them
        sqrw = 0;
    end

    methods
        function obj = mdf_connector
            % constructor
        end
    end

    methods
        % 
        function res = getSortQueryRunWeight(obj)
            % function res = obj.getSortQueryRunWeight()
            %
            % return the weight to be used when ordering the habitats
            % for a blind query run
            % this function is place mark for getsqrtw
            res = obj.getsqrw();
        end
    end

    methods (Abstract)
        res = getsqrw();
        res = getMethods(obj);
        res = save(obj,indata);
        res = find(obj,indata);
        res = delete(obj,indata);
    end
    
end

