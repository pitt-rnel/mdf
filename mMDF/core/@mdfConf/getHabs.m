function Hs = getHabs(obj,selection)
    % Hs = mdfConf.getHabs(obj,selection)
    %
    % return all habitats for the selected ecosystem
    %
    % output
    %   Hs = (cell of struct) ecosystem habitats
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected ecosystem
    %
    
    % use getEco
    eco = struct();
    if ( nargin < 2 ) 
        eco = obj.getEco();
    else
        eco = obj.getEco(selection);
    end %if
    
    Hs = struct;
    % check if we have the constants field
    if ( isa(eco,'struct') && ...
            isfield(eco,'environment') )
        Hs = eco.habitats.habitat;
    end %if
end %function
