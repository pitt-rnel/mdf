classdef mdfConf < handle
   
    properties
        % if we need to use internal or external library for json
        matlab_json_api;
        json_api;

    end %properties

    methods
        % constructor
        function obj = mdfConf()
            obj.matlab_json_api = (exist('jsondecode') == 5);
            if obj.matlab_json_api
                obj.json_api = 'MATLAB';
            else
                obj.json_api = 'JSONLAB';
            end %if
        end %function
    end %methods

    methods 
        % return specific constant
        function C = getConstant(obj, constant)
            C = [];
            switch (constant)
                case 'MDF_MATLAB_JSONAPI'
                    C = obj.matlab_json_api;
                case 'MDF_JSONAPI'
                    C = obj.json_api;
            end %switch
        end %function
    end %methods

    methods (Static)
        % static method in order to return the global instance
        function obj = getInstance()
            global omdfc;
            obj = omdfc.conf;
        end %function
    end %methods
end %classdef

