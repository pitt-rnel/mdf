function [res, outsource, outdest] = rmUnidirectionalLink(insource,indest,sProp)
    % function [res, outsource, outdest] = rmBidirectionalLink(insource,indest,sProp)
    %
    % remove a unidirectional link between source object.
    % 
    % INPUT
    % - insource : (uuid or mdfObj) source object or uuid of the source object
    % - indest   : (uuid or mdfObj) destination object or uuid of the destination object
    % - sProp    : (string) property under which the destination object will be
    %              found in the source object
    %
    % OUTPUT
    % - res       : (boolean) true if success
    % - outsource : (mdfObj) source mdf object
    % - outdest   : (mdfObj) destination mdf object
    %

    % get source uuid and object
    [uSource, oSource] = mdf.getUAO(insource);
    
    % get dest uuid and object
    [uDest, oDest] = mdf.getUAO(indest);
    
    % remove link from source object
    res = oSource.rmLink(sProp,oDest);

    % prepare output
    if nargout > 1
        outsource = oSource;
        outdest = oDest;
    end %if

        
end %function
