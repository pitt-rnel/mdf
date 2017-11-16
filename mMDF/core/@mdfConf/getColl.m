function C = getColl(obj,selection)
    % C = mdfConf.getColl(obj,selection)
    %
    % return the selected collection
    %
    % output
    %   C = (struct) collection
    % input
    %   obj = this object
    %   selection = (string,integer) human or machine name or index of the
    %   collection requested
    %
    
    % set selection from input
    sel = obj.getCollectionIndex(selection);

    % initialize output structure
    C = struct;
    % check if we have a selection defined
    if ~isempty(sel) && isnumeric(sel) && ~isnan(sel)
        % extract selected configuration
        C = obj.confData.collections.collection{sel};
    end %if
end %function

