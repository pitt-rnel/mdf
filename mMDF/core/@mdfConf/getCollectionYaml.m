function yaml = getCollectionYaml(obj,selection)
    % YAML = rneldbconf.getCollectionYaml(obj,selection)
    %
    % return the collection yaml configuration for the selected configuration
    %
    % output
    %   YAML = (boolean) true if we need to create yaml files for each mdf
    %          object with metadata
    %   
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected configuration
    %
    
    % check if we got selection
    if nargin > 1
        % set selection
        obj.select(selection);
    end
    
    % get configuration
    conf = obj.getCollectionConf(obj.selection);
    yaml = conf.YAML;
end