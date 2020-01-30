classdef mdfObj < handle
   
    properties
        % if we need to use internal or external library for json
        uuid;
    end %properties

    methods
        % constructor
        function obj = mdfObj(uuid)
            obj.uuid = uuid;
        end %function
    end %methods

    methods 
    end %methods

    methods (Static)
    end %methods
end %classdef

