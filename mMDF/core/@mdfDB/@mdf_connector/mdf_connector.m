classdef (Sealed) mdf_connector < handle

    properties
        % sort query run weight
        % it is the number used when you want to order the habitats
        % to run a query on all of them
        sqrw = 0;
        %
        % habitat configuration
        habitat = [];
        %
        % selection string
        selectionString = '';
    end

    methods
        function obj = mdf_connector(habitat)
            % constructor
            obj.habitat = habitat;
            obj.getSS();
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
        end %function
        %
        % 
        function res = getOperations(obj)
            % function res = obj.getOperations()
            %
            % return the operations that this connector allows
            % this function is place mark for getsqrtw
            res = obj.getOps();
        end %function
        %
        % 
        function ss = getSS(obj)
            if isempty(obj.selectionString)
                % prepare selector string and habuuid
                for i1 = [1:length(obj.habitat.objects.object)]
                    for i2 = [1:length(obj.habitat.components.component)]
 
                        % connection string:
                        % group.object.component[:data-prop]
                        res{end+1} = [ ...
                            obj.habitat.group ':' ...
                            obj.habitat.objects.object{i1} ':' ...
                            obj.habitat.components.component{i2} ];
                    end %for
                end %for
            end %if
            ss = obj.selectionString;
        end %function

    end

    methods (Abstract)
        res = getsqrw();
        res = getMethods(obj);
        res = save(obj,indata);
        res = find(obj,indata);
        res = delete(obj,indata);
        res = getOps(obj);
    end
    
end

