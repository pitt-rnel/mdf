function C = getConf(obj,selection)
    % C = rneldbconf.getConf(obj,selection)
    %
    % return the selected configuration
    % if human or machine name or index is provided, it return data for that specific collection,
    % otherwise returns complete configuration    
    %
    % output
    %   C = (struct) configuration data
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected configuration
    %
    
    % initialize output structure
    C = struct;
    
    % check if we got selection
    if nargin > 1
        % get selection
        sel = obj.getCollectionIndex(selection);
        C = obj.confData.collections.collection{sel};
    else
        C = obj.confData;
    end %if
    
end %function