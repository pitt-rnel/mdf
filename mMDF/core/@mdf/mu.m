function [total,used,free] = mu()
    % function [total,used,free] = mu()
    %
    % wrapper function with abbreviated name for memoryUsage function
    % please refer to memoryUsage function for help
    
    [total,used,free] = mdf.memoryUsage();
end % function