function res = rmUnidirectionalLink(source,dest,sProp)
    % function res = rmBidirectionalLink(source,dest,sProp)
    %
    % remove a unidirectional link between source object.
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
                'rf:rmBidirectionalLink', ...
                'Invalid Source object'));
    end %if
    
    if ~any(strcmp(oSource.def.rf_links.rf_fields,sProp))
        throw( ...
            MException( ...
                'rf:rmBidirectionalLink', ...
                'Invalid Source Object property'));
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
                'rf:rmBidirectionalLink', ...
                'Invalid Destination object'));
    end %if  
    
    % remove link from source object
    res = oSource.rmLink(sProp,dest);
        
end %function