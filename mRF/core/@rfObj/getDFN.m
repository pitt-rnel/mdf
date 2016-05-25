function dfn = getDFN(obj,filtered)
    % function dfn = obj.getDFN(filtered)
    %
    % Please refer to rfObj.getDataFileName function for help

    % check if user specified filtered or we should use default value
    if nargin < 2 || ~isa(filtered,'logical')
        filtered = true;
    end

    dfn = obj.getDataFileName(filtered)
end %function