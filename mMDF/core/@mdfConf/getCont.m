function C = getCont(obj,selection)
    % C = mdfConf.getCont(obj,selection)
    %
    % return the selected container
    %
    % output
    %   C = (struct) container
    % input
    %   obj = this object
    %   selection = (string,integer) human or machine name, uuid or index of the
    %   container requested
    %
    
    % set selection from input
    sel = obj.getContainerIndex(selection);

    % initialize output structure
    C = struct;
    % check if we have a selection defined
    if ~isempty(sel) && isnumeric(sel) && ~isnan(sel)
        % extract selected configuration
        C = obj.confData.containers.container{sel};
    end %if
end %function

