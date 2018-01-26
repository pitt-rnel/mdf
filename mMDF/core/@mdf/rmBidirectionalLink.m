function [res, outsource, outdest]  = rmBidirectionalLink(insource,indest,sProp,dProp)
    % function [res, outsource, outdest] = rmBidirectionalLink(insource,indest,sProp,dProp)
    %
    % remove a bidirectional link between source and destination object.
    % 
    % INPUT
    % - insource : (uuid or mdfObj) source object or uuid of the source object
    % - indest   : (uuid or mdfObj) destination object or uuid of the destination object
    % - sProp    : (string) property under which the destination object will be
    %              found in the source object
    % - sDest    : (string) property under which the source object will be
    %              found in the destination object

    % get source uuid and object
    [uSource, oSource] = mdf.getUAO(insource);
    
    % get dest uuid and object
    [uDest, oDest] = mdf.getUAO(indest);
    
    % check that property is valid
    %if ~any(strcmp(oDest.mdf_def.mdf_links.mdf_fields,dProp))
    %    throw( ...
    %        MException( ...
    %            'mdf:rmBidirectionalLink', ...
    %            'Invalid Destination Object property'));
    %end %if
    
    % remove link from source object
    res1 = oSource.rmLink(sProp,oDest);
    
    % remove link from destination object
    res2 = oDest.rmLink(dProp,oSource);

    % prepare output
    res = res1 && res2;
    if nargout > 1
        outsource = oSource;
        outdest = oDest;
    end %if
    
end %function
