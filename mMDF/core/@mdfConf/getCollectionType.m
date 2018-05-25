function C = getCollectionType(obj,selection)
    % C = rneldbconf.getCollectionTpe(obj,selection)
    %
    % return the collection type of selected configuration
    %
    % output
    %   C = (char) collection type
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
    C = "UNKNOWN";
    % check if we have a selection defined
    if ~isempty(obj.selection)
        % extract selected configuration
        C = obj.confData.configurations.configuration{obj.selection}.constants.MDF_COLLECTION_TYPE;
    end
end