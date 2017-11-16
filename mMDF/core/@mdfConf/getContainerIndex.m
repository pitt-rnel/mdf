function sel = getContainerIndex(obj,indata)
    % function sel = obj.getContainerIndex(indata)
    %
    % given human or machine name, uuid or index,
    % it returns the index of the container within the container array
    % or NaN if name is invalid or index is out of range
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
                    {obj.menu.containers.human_name}));
            if isempty(sel)
            	% tries with machine names
                sel = find( ...
                	cellfun( ...
                    	@(s) strcmp(s,indata), ...
                        {obj.menu.containers.machine_name}));
            end %if
            if isempty(sel)
            	% tries with uuid
                sel = find( ...
                	cellfun( ...
                    	@(s) strcmp(s,indata), ...
                        {obj.menu.containers.uuid}));
            end %if
        case {'single','double'}
            try
                temp = obj.confData.containers.container{indata};
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