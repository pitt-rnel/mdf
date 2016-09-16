function res = rmUnidirectionalLink(source,dest,sProp)
    % function res = rmBidirectionalLink(source,dest,sProp)
    %
    % remove a unidirectional link between source object.
    % 
    % INPUT
    % - source : (uuid or mdfObj) source object or uuid of the source object
    % - dest   : (uuid or mdfObj) destination object or uuid of the destination object
    % - sProp  : (string) property under which the destination object will be
    %            found in the source object

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
%     % check that object and uuid are valid
%     if isempty(oSource) || isempty(uSource)
%         throw( ...
%             MException( ...
%                 'mdf:rmBidirectionalLink', ...
%                 'Invalid Source object'));
%     end %if
%     % check that property on source object is fine
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
%     % check that destination object and uuid are valid
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
    
    % remove link from source object
    res = oSource.rmLink(sProp,dest);
        
end %function
