function [res, outsource, outdest] = abl(insource,indest,sProp,dProp)
    % function [res, outsource, outdest] = abl(insource,indest,sProp,dProp)
    %
    % short cut to function addBidirectionalLink
    % check addBidirectionalLink help for more info
    %
    
    [res, oSource, oDest] = mdf.addBidirectionalLink(insource,indest,sProp,dProp);

    if nargout > 1
        outsource = oSource;
        outdest = oDest;
    end %if
    
end %function
