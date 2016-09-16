function res = rmBidirectionalLink(source,dest,sProp,dProp)
    % function res = rmBidirectionalLink(source,dest,sProp,dProp)
    %
    % remove a bidirectional link between source and destination object.
    % 
    % INPUT
    % - source : (uuid or mdfObj) source object or uuid of the source object
    % - dest   : (uuid or mdfObj) destination object or uuid of the destination object
    % - sProp  : (string) property under which the destination object will be
    %            found in the source object
    % - sDest  : (string) property under which the source object will be
    %            found in the destination object

%     oSource = [];
%     uSource = [];
%     if ischar(source)
%         % we got uuid for source object
%         % load object
%         uSource = source;
%         oSource = mdfObj.load(uSource);
%         
%     elseif isa(source,'mdfObj')
%         % we got source object
%         % extract uuid
%         oSource = source;
%         uSource = source.uuid;
%         
%     end %if
%     % check if objecy and uuid are empty
%     if isempty(oSource) || isempty(uSource)
%         throw( ...
%             MException( ...
%                 'mdf:rmBidirectionalLink', ...
%                 'Invalid Source object'));
%     end %if
%     % makes sure that the property is valid
%     if ~any(strcmp(oSource.mdf_def.mdf_links.mdf_fields,sProp))
%         throw( ...
%             MException( ...
%                 'mdf:rmBidirectionalLink', ...
%                 'Invalid Source Object property'));
%     end %if
% 
%     oDest = [];
%     uDest = [];
%     if ischar(dest)
%         % we got uuid for destination object
%         % load object
%         uDest = dest;
%         oDest = mdfObj.load(uDest);
%         
%     elseif isa(dest,'mdfObj')
%         % we got destination object
%         % extract uuid
%         oDest = dest;
%         uDest = dest.uuid;
%         
%     end %if
%     % check that object and uuid are valid
%     if isempty(oDest) || isempty(uDest)
%         throw( ...
%             MException( ...
%                 'mdf:rmBidirectionalLink', ...
%                 'Invalid Destination object'));
%     end %if  
    
    % get source uuid and object
    [uSource, oSource] = mdf.getUAO(source);
    
    % get dest uuid and object
    [uDest, oDest] = mdf.getUAO(dest);
    
    % check that property is valid
    if ~any(strcmp(oDest.mdf_def.mdf_links.mdf_fields,dProp))
        throw( ...
            MException( ...
                'mdf:rmBidirectionalLink', ...
                'Invalid Destination Object property'));
    end %if
    
    % remove link from source object
    res = oSource.rmLink(sProp,dest);
    
    % remove link from destination object
    res = oDest.rmLink(dProp,source);
    
end %function
