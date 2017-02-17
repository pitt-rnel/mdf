function E = getEnv(obj,selection)
    % E = mdfConf.getEnv(obj,selection)
    %
    % return the selected ecosystem environment
    %
    % output
    %   E = (struct) ecosystem environment
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected ecosystem
    %

    % get selection
    s = obj.selection;
    if ( nargin < 2 )
        s = selection;
    end %if    

    % use getEco
    eco = obj.getEco(selection);
    
    E = struct;
    % check if we have the constants field
    if ( isa(eco,'struct') && ...
            isfield(eco,'environment') )
        E = eco.environment;
    end %if
end %function

