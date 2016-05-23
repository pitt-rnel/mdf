function res = addUnidirectionalLink(source,dest,sProp)
    % function res = addUnidirectionalLink(source,dest,sProp)
    %
    % create a unidirectional link from source object to destination object
    % under prop property in the source object.
    % destination object is not aware of the link
    %
    % INPUT
    % - source : (uuid or rfObj) source object or uuid of the source object
    % - dest   : (uuid or rfObj) destination object or uuid of the destination object
    % - sProp  : (string) property under which the destination object will be
    %            found in the source object
    
    oSource = [];
    uSource = [];
    if ischar(source)
        % we got uuid for source object
        % load object
        uSource = source;
        oSource = rfObj.load(uSource);
        
    elseif isa(source,'rfObj')
        % we got source object
        % extract uuid
        oSource = source;
        uSource = source.uuid;
        
    end %if
    if isempty(oSource) || isempty(uSource)
        throw( ...
            MException( ...
                'rf:addUnidirectionalLink', ...
                'Invalid Source object'));
    end %if

    oDest = [];
    uDest = [];
    if ischar(dest)
        % we got uuid for destination object
        % load object
        uDest = dest;
        oDest = rfObj.load(uDest);
        
    elseif isa(dest,'rfObj')
        % we got destination object
        % extract uuid
        oDest = dest;
        uDest = dest.uuid;
        
    end %if
    if isempty(oDest) || isempty(uDest)
        throw( ...
            MException( ...
                'rf:addUnidirectionalLink', ...
                'Invalid Destination object'));
    end %if
    
    % add destination object under designated property in source object
    res = oSource.addLink(sProp,oDest,'u');
    
end %function