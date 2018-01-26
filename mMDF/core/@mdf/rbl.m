function [res, outsource, outdest] = rbl(insource,indest,sProp,dProp)
    % function [res, outsource, outdest] = rbl(insource,indest,sProp,dProp)
    %
    % short cut to function rmBidirectionalLink
    % check rmBidirectionalLink help for more info
    %
    
    [res, oSource, oDest] = mdf.rmBidirectionalLink(insource,indest,sProp,dProp);

    % prepare output
    if nargout > 1
        outsource = oSource;
        outdest = oDest;
    end %if

end %function
