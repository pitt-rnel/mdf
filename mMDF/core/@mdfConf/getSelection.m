function [n, varargout]  = getSelection(obj)
    % [n, m, i] = mdfConf.getSelection(obj)
    %
    % return the current configuration selected
    %
    % output
    %   n = configuration name
    %   m = (optional) configuration machine name
    %   i = (optional) configuration index in names array
    %
    
    n = 0;
    if nargout > 1
        varargout{1} = "";
    end %if
    if nargout > 2
        varargout{2} = 0;
    end %if
    
    % check if
    % - we already loaded the configuration
    % - select one configuration
    if ( ~isempty(obj.selection) && ...
            obj.selection > 0 && ...
            ~isempty(obj.confData) && ...
            isa(obj.confData,'struct') && ...
            isfield(obj.confData,'configurations') && ...
            isa(obj.confData.configurations,'struct') && ...
            isfield(obj.confData.configurations,'configuration') && ...
            isa(obj.confData.configurations.configuration,'cell') )
        % assign name
        n = obj.confData.configurations.names{obj.selection};
        % check if we need to prepare additional output
        if nargout > 1
            % prepare additional output
            varargout = cell(1,min(nargout,3));
            varargout{1} = obj.confData.configurations.machines{obj.selection};
            if (nargout > 2 )
                 varargout{2} = obj.selection;         
            end 
        end
    end    
end

