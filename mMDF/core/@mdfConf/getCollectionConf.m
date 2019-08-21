function [arg1,arg2,arg3] = getCollectionConf(obj,selection)
    % C = rneldbconf.getCollectionconf(obj,selection)
    % [DB,YAML,DATA] = rneldbconf.getCollectionconf(obj,selection)
    %
    % return the collection configuration for the selected configuration
    %
    % output
    %   C = (struct) collection configuration
    %     or
    %   DB   = (string) db to be used. Only option: MONGODB
    %   YAML = (boolean) true if we need to create yaml files for each mdf
    %          object with metadata
    %   DATA = (string) where to save the data
    %          - MATFILE,FILE,MAT,M : in hdf5 matlab files
    %          - DATABASE,DB,D : in the database within the same document
    %            created for the metadata
    %
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected configuration
    %
   
    arg1 = [];
 
    % check if we got selection
    if nargin > 1
        % set selection
        obj.select(selection);
    end
    
    % initialize output structure
    res = [];
    % check if we have a selection defined
    if ~isempty(obj.selection)
        % extract selected configuration
        try
            res = obj.confData.configurations.configuration{obj.selection}.constants.MDF_COLLECTION;
        catch
            % nothing;
        end %try/catch
    end
    if ~isempty(res)
        if nargout > 1
            arg1 = res.DB;
            arg2 = res.YAML;
            arg3 = res.DATA;
        else
            arg1 = res;
        end %if
    end %if
end
