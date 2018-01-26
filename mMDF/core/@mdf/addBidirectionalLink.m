function [res, outsource, outdest] = addBidirectionalLink(insource,indest,sProp,dProp)
    % function [res, outsource, outdest] = addBidirectionalLink(insource,indest,sProp,dProp)
    %
    % create a bidirectional link from source object to destination object
    % under sProp property in the source object and dProp in the
    % destination object.
    % this link allows to go from source to dest and viceversa
    %
    % INPUT
    % - insource : (uuid or mdfObj) source object or uuid of the source object
    % - indest   : (uuid or mdfObj) destination object or uuid of the destination object
    % - sProp    : (string) property under which the destination object will be
    %              found in the source object
    % - sDest    : (string) property under which the source object will be
    %              found in the destination object
    %
    % OUTPUT
    % - res       : (boolean) true if success
    % - outsource : (mdfObj) source mdf object
    % - outdest   : (mdfObj) destination mdf object
    %
    
    % get uuid and object for source
    [uSource, oSource] = mdf.getUAO(insource);
    
    % get uuid and object for dest
    [uDest, oDest] = mdf.getUAO(indest);
    
    % add destination object under designated property in source object
    res1 = oSource.addLink(sProp,oDest,'b');
    
    % add Source under Source property in Dest object
    res2 = oDest.addLink(dProp,oSource,'b');

    % prepare output
    res = res1 && res2;
    if nargout > 1
        outsource = oSource;
        outdest = oDest;
    end %if
    
end %function
