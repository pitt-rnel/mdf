function mfn = getMFN(obj,filtered)
    % function mfn = obj.getMFN(filtered)
    %
    % Please refer to mdfObj.getMetadataFileName function for help

    % check if user specified filtered or we should use default value
    if nargin < 2 || ~isa(filtered,'logical')
        filtered = true;
    end

    mfn = obj.getMetadataFileName(filtered);
end %function