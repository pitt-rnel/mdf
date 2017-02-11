function C = getC(obj,selection)
    % C = rneldbconf.getC(obj,selection)
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
        tC = obj.getConf();
    else
        tC = obj.getConf(selection);
    end
    
    C = struct;
    % check if we have the constants field
    if ( isa(tC,'struct') && ...
            isfield(tC,'environment') )
        C = tC.environment;
    end
end