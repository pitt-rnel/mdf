function data = getCollectionData(obj,selection)
    % data = rneldbconf.getCollectionData(obj,selection)
    %
    % return the collection data configuration for the selected configuration
    %
    % output
    %   DATA = (string) where to save the data
    %          - MATFILE,FILE,MAT,M : in hdf5 matlab files
    %          - DATABASE,DB,D : in the database within the same document
    %            created for the metadata
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
    data = conf.DATA;
end