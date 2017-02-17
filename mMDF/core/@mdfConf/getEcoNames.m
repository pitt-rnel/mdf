function [hN, mN] = getEcoNames(obj)
    % [hN, mN] = mdfConf.getList(obj)
    %
    % return the list of names of available ecosystems 
    %
    % output
    %   hN = list of ecosystems human names
    %   mM = (optional) list of ecosystems  machine names
    %
    
    % initialize output structure
    hN = {};
    if nargout > 1 
        mN = [];
    end %if
    
    % extract list of configurations
    try
        hN = obj.confData.universe.names;
        if nargout > 0
            mM = obj.confData.universe.machines;
        end %if
    catch
        % nothing to do
    end % try/catch
end %function

