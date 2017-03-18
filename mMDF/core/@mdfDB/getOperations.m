function res = getOperations(obj,habuuid)
    % function res = obj.getOperations(habuuid)
    %
    % this function is just a place mark for getOps function
    % please check getOps help for more info
    %

    if nargin > 1
        res = obj.getOps(habuuid);
    else
        res = obj.getOps();
    end %if

end %function 
