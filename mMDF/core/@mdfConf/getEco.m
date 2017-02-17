function E = getEco(obj,selection)
    % E = mdfConf.getConf(obj,selection)
    %
    % return the selected ecosystem
    %
    % output
    %   E = (struct) ecosystem
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected configuration
    %
    
    % check if we got a selection in input
    s = obj.selection;
    if nargin > 1
        % set selection from input
        s = selection;
    end %if
    
    % initialize output structure
    E = struct;
    % check if we have a selection defined
    if ~isempty(s) && isnumeric(s)
        % extract selected configuration
        E = obj.confData.universe.ecosystem{s};
    end %if
end %function

