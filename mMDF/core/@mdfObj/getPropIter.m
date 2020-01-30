function iter = getPropIter(obj,prop,dir,type)
    %
    % provide the vector of indexes to iterate over all the items within
    % the property requested
    %
    % Input
    % - prop: (string) name of the property that we want to iterate on. It
    %         can be a child or a link
    % - dir : (string) direction in which you traverse the items in the
    %         property. Values: 'asc or 'desc'. Default: desc
    % - type: (string) type of the property requested. Values: 'children'
    %         or 'links'. Is not mandatory if there are no duplicate names
    %
    % Output
    % - iter: (integer) vector from 1 to the number of items if ascending
    %         order is selected, from number of items to 1 if descending.
    %         It returns an empty vector if the property does not exists or
    %         is empty
    %
    
    iter = [];
    
    if nargin <= 2
        % no dir 
        dir = 'asc';
    else
        dir = lower(dir);
        if ~any(strcmp({'asc','desc'},dir))
            return;
        end %if
    end %if
    
    if nargin <= 3
        % no type
        pl = obj.getLen(prop);
    else
        % user specified type
        pl = obj.getLen(prop,type);
    end %if
    
    if ~isnan(pl) & pl > 0
        switch (dir)
            case 'asc'
                iter = [1:1:pl];
            case 'desc'
                iter = [pl:-1:1];
        end %switch
    end %if
    
end %function
