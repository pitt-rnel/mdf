function [n, varargout]  = getSelection(obj)
    % [n, m, i] = rfConf.getSelection(obj)
    %
    % return the current configuration selected
    %
    % output
    %   n = configuration name
    %   m = (optional) configuration machine name
    %   i = (optional) configuration index in names array
    %
    
    % check if
    % - we already loaded the configuration
    % - select one configuration
    if ( ~isempty(obj.selection) && ...
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

