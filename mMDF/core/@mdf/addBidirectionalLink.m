function res = addBidirectionalLink(source,dest,sProp,dProp)
    % function res = addBidirectionalLink(source,dest,sProp,dProp)
    %
    % create a bidirectional link from source object to destination object
    % under sProp property in the source object and dProp in the
    % destination object.
    % this link allows to go from source to dest and viceversa
    %
    % INPUT
    % - source : (uuid or mdfObj) source object or uuid of the source object
    % - dest   : (uuid or mdfObj) destination object or uuid of the destination object
    % - sProp  : (string) property under which the destination object will be
    %            found in the source object
    % - sDest  : (string) property under which the source object will be
    %            found in the destination object

    
    oSource = [];
    uSource = [];
    if ischar(source)
        % we got uuid for source object
        % load object
        uSource = source;
        oSource = mdfObj.load(uSource);
        
    elseif isa(source,'mdfObj')
        % we got source object
        % extract uuid
        oSource = source;
        uSource = source.uuid;
        
    end %if
    if isempty(oSource) || isempty(uSource)
        throw( ...
            MException( ...
                'mdf:addUnidirectionalLink', ...
                'Invalid Source object'));
    end %if

    oDest = [];
    uDest = [];
    if ischar(dest)
        % we got uuid for destination object
        % load object
        uDest = dest;
        oDest = mdfObj.load(uDest);
        
    elseif isa(dest,'mdfObj')
        % we got destination object
        % extract uuid
        oDest = dest;
        uDest = dest.uuid;
        
    end %if
    if isempty(oDest) || isempty(uDest)
        throw( ...
            MException( ...
                'mdf:addUnidirectionalLink', ...
                'Invalid Destination object'));
    end %if
    
    % add destination object under designated property in source object
    res = oSource.addLink(sProp,oDest,'b');
    
    % add Source under Source property in Dest object
    res = oDest.addLink(dProp,oSource,'b');
    
end %function