function [res, outsource, outdest] = addUnidirectionalLink(insource,indest,sProp)
    % function [res, outsource, outdest] = addUnidirectionalLink(insource,indest,sProp)
    %
    % create a unidirectional link from source object to destination object
    % under prop property in the source object.
    % destination object is not aware of the link
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

    % get uuid and object for source
    [uSource, oSource] = mdf.getUAO(insource);
    
    % get uuid and object for dest
    [uDest, oDest] = mdf.getUAO(indest);
    
    % add destination object under designated property in source object
    res = oSource.addLink(sProp,oDest,'u');

    % prepare output
    if nargout > 1
        outsource = oSource;
        outdest = oDest;
    end %if

    
end %function
