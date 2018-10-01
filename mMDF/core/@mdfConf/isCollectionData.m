function res = isCollectionData(obj,value,selection)
    % res = rneldbconf.isCollectionData(obj,value,selection)
    %
    % return true if the collection data configuration is the one indicated
    % in value
    %
    % output
    %   res = (boolean) true if the collection data configuration matches
    %                   the value passed in.
    %          Possible values:
    %          - MATFILE  : in hdf5 matlab files
    %          - DATABASE : in the database within the same document
    %            created for the metadata
    %   
    % input
    %   obj       = this object
    %   value     = (string) value to test against. Please see the list above 
    %   selection = (string,integer) (optional) selected configuration
    %
    
    % check if we got selection
    if nargin > 2
        % set selection
        obj.select(selection);
    end
    
    % get configuration
    conf = obj.getCollectionConf(obj.selection);
    res = strcmp(conf.DATA,value);
end