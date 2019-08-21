function C = getConstants(obj,selection)
    % C = rneldbconf.getConstants(obj,selection)
    %
    % return the selected configuration constants
    %
    % output
    %   C = (struct) configuration data
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected configuration
    %
    
    % use getConf
    tC = struct();
    if ( nargin < 2 ) 
        tC = obj.getConfiguration();
    else
        tC = obj.getConfiguration(selection);
    end
    
    C = struct;
    % check if we have the constants field
    if ( isa(tC,'struct') && ...
            isfield(tC,'constants') )
        C = tC.constants;
    end
end
