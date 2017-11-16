function E = getEnv(obj,selection)
    % E = mdfConf.getEnv(obj,selection)
    %
    % return the selected collections environment
    %
    % output
    %   E = (struct) collections environment
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected collections
    %               default: GLOBAL
    %

    % get selection
    s = 'GLOBAL';
    if ( nargin > 1 )
        s = selection;
    end %if    

	% get index of the collection. it will be NaN if Global or not found
    sel = obj.getCollectionIndex(s);
    % extract global environment by default
    E = obj.confData.environment;
    % if we have selection, we got the specific environment
    if ~isnan(sel) & ~isempty(sel)
        E = obj.confData.collections.collection{sel}.environment;
    end %if
end %function

