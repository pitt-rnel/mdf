function [res, outsource, outdest] = aul(insource,indest,sProp)
    % function [res, outsource, outdest] = aul(insource,indest,sProp)
    %
    % short cut to function addUnidirectionalLink
    % check addUnidirectionalLink help for more info
    %
    
    [res, oSource, oDest] = mdf.addUnidirectionalLink(insource,indest,sProp);

    % prepare output
    if nargout > 1
        outsource = oSource;
        outdest = oDest;
    end %if

    
end %function
