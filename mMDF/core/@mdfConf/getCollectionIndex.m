function sel = getCollectionIndex(obj,indata)
    % function sel = obj.getCollectionIndex(indata)
    %
    % given human or machine name or index,
    % it returns the index of the collection within the collections array
    % or NaN if naemis invalid or index is out of range
    %
    % This is intended to be an internal method only
    %
    
    % initialize output value
    sel = NaN;
    
    % check which type of input we got
    switch (class(indata))
        case 'char'
            % first check in human names
            sel = find( ...
            	cellfun( ...
                	@(s) strcmp(s,indata), ...
                    {obj.menu.collections.human_name}));
            if isempty(sel)
            	% tries with machine names
                sel = find( ...
                	cellfun( ...
                    	@(s) strcmp(s,indata), ...
                        {obj.menu.collections.machine_name}));
            end %if
            if isempty(sel)
            	% tries with uuid
                sel = find( ...
                	cellfun( ...
                    	@(s) strcmp(s,indata), ...
                        {obj.menu.collections.uuid}));
            end %if
        case {'single','double'}
            try
                temp = obj.confData.collections.collection{indata};
                sel = indata;
            catch
                % if we get here, it means that the index that was passed
                % in, is not valid
                sel = NaN;
            end %try/catch
    end %switch
    
    if ~isnumeric(sel) && ~isnan(sel) && isempty(sel)
        sel = NaN;
    end %if

end %function