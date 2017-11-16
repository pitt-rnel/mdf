function [n, varargout]  = getSelection(obj)
    % [n, m, i] = mdfConf.getSelection(obj)
    %
    % return which collections are set to be open at startup
    %
    % output
    %   n = configuration human name
    %   m = (optional) configuration machine name
    %   i = (optional) configuration index in names array
    %
    
    % check if
    % - we already loaded the configuration
    % - select one configuration
    if ( ~isempty(obj.selection) && ...
            ~isempty(obj.confData) && ...
            isa(obj.confData,'struct') && ...
            isfield(obj.confData,'collections') && ...
            isa(obj.confData.collections,'struct') && ...
            isfield(obj.confData.collections,'collection') && ...
            isa(obj.confData.collections.collection,'cell') )
        % assign name
        n = {obj.menu.collections(obj.selection).human_name};
        % check if we need to prepare additional output
        if nargout > 1
            % prepare additional output
            varargout = cell(1,min(nargout,3));
            varargout{1} = {obj.menu.collections(obj.selection).machine_name};
            if (nargout > 2 )
                 varargout{2} = obj.selection;
            end 
        end
    end    
end

