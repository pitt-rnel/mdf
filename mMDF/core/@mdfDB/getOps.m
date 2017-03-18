function res = getOps(obj,habuuid)
    % function res = obj.getOps(habuuid)
    %
    % return the operations allowed by the requested habuuid
    % if no habuuid is provided, it will return the operations available
    % for all of them
    %

    res = {};

    if nargin > 1
        % we got habuuid
        % get habitat object
        ohab = obj.getH(habuuid);
        % return operation of the habitat
        res = ohab.getOps();

    else
        % no habuuid
        % we are going to return all the operations for all the habitats
        
        % loops on all the habitats
        for i1 = 1:length(obj.habitats.uuids)
            % get habitat
            ohab = obj.getH(obj.habitats.uuids{i1});
            % insert it in the output cell array
            res{end+1} = ohab.getOps();

        end %for

    end %if

end %function 
