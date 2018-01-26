function [res, outsource, outdest] = rul(insource,indest,sProp)
    % function [res, outsource, outdest] = rul(insource,indest,sProp)
    %
    % short cut to function rmUnidirectionalLink
    % check rmUnidirectionalLink help for more info
    %
    
    [res, oSource, oDest] = mdf.rmUnidirectionalLink(insource,indest,sProp);

    % prepare output
    if nargout > 1
        outsource = oSource;
        outdest = oDest;
    end %if
    
end %function
