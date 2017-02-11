function C = getConf(obj,selection)
    % C = rneldbconf.getConf(obj,selection)
    %
    % return the selected configuration
    %
    % output
    %   C = (struct) configuration data
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected configuration
    %
    
    % check if we got selection
    if nargin > 1
        % set selection
        obj.select(selection);
    end
    
    % initialize output structure
    C = struct;
    % check if we have a selection defined
    if ~isempty(obj.selection)
        % extract selected configuration
        C = obj.confData.universe.ecosystem{obj.selection};
    end
end