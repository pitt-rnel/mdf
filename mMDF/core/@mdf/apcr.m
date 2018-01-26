function [res, outparent, outchild] = apcr(inparent,inchild,prop)
    % function [res, outparent, outchild] = apcr(inparent,inchild,prop)
    %
    % short cut to function addParentChildRelation
    % check addParentChildRelation help for more info
    %

    [res, oParent, oChild] = mdf.addParentChildRelation(inparent,inchild,prop);
    
    if nargout > 1
        outparent = oParent;
        outchild = oChild;
    end %if

end %function
