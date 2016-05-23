function [L, varargout] = getList(obj)
    % [L, M] = rfConf.getList(obj)
    %
    % return the list of available configurations
    %
    % output
    %   L = list of configuration names
    %   M = (optional) list of configuration machine names
    %
    
    % initialize output structure
    L = {};
    if nargout > 0 
        varargout{1} = struct;
    end
    
    % extract list of configurations
    try
        L = obj.confData.configurations.names;
        if nargout > 0
            varargout{1} = obj.confData.configurations.machines;
        end
    catch
        % nothing to do
    end
end
