function [res, outparent, outchild] = rpcr(inparent,inchild,prop)
    % function [res, outparent, outchild] = rpcr(inparent,inchild,prop)
    %
    % short cut to function rmParentChildRelation
    % check rmParentChildRelation help for more info
    %
    
    [res, oParent, oChild] = mdf.rmParentChildRelation(inparent,inchild,prop);

    if nargout > 2
        outparent = oParent;
        outchild = oChild;
    end %if

end %function
