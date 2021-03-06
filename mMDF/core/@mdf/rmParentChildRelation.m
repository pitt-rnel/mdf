function [res, outparent, outchild] = rmParentChildRelation(inparent,inchild,prop)
    % function [res, outparent, outchild] = rmParentChildRelation(inparent,inchild,prop)
    %
    % remove a parent-child relationship between object parent and child.
    % in parent object, child should be accessible under the property prop
    %
    % INPUT
    % - inparent : (uuid or mdfObj) parent object or uuid of the parent object
    % - inchild  : (uuid or mdfObj) child objecy or uuid of the child object
    % - prop     : (string) property under which the child object will be
    %              found in the parent object
    %
    % OUTPUT
    % - res       : (boolean) true if successful
    % - outparent : (mdfObj) parent mdf object
    % - outchild  : (mdfObj) child object


    % get parent uuid and object
    [uParent, oParent] = mdf.getUAO(inparent);
    
    % get child uuid and object 
    [uChild, oChild] = mdf.getUAO(inchild);

    % add child under designated property in parent
    res1 = oParent.rmChild(prop,oChild);
    
    % add parent under parent property in child object
    res2 = oChild.rmParent(oParent);

    res = res1 && res2;
    if nargout > 1
        outparent = oParent;
        outchild = oChild;
    end %if
    
end %function
