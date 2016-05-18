function res = rmLink(obj, prop, link)
    % function res = obj.rmLink(obj, prop, link)
    %
    % remove specific link or all links under prop
    %
    % input:
    % - prop  : (string) name of the link property
    % - link : (string or rfObj) link to be removed. Optional
    %           if no link is provided, all the links under prop will
    %           be removed
    %
    
    res = obj;
    
    if nargin < 2
        throw(MException('rfObj:rmLink','Invalid number of arguments'));
    end %if
    
    % check if prop exists
    ip = find(strcmp(obj.def.rf_links.rf_fields,prop));
    if ~isfield(obj.def.rf_links,prop) || isempty(ip)
        throw(MException('rfObj:rmLink','Invalid prop name or object corrupted'));
    end %if
    
    % check if we got link or we need to remove everything
    if nargin >= 3
        % single link to be removed
        %
        % get uuid from link
        if isa(link,'rfObj')
            uuid = link.uuid;
            olink = link;
        elseif isa(link,'char')
            uuid = link;
            olink = rfObj.load(uuid);
        else
           throw(MException('rfObj:rmLink','Invalid links property type.')); 
        end %if
        % find link in list
        pos = find(strcmp(obj.def.rf_links.(prop).rf_uuid,uuid));
        if isempty(pos)
           throw(MException('rfObj:rmLink','Link uuid not found in links property.')); 
        end %if
        % remove link from all the lists
        obj.def.rf_links.(prop)(pos) = [];
    else
        % reset property
        obj.def.rf_links.(prop) = [];
    end %if
    % remove type and directionality if necessary
    if length(obj.def.rf_links.(prop)) == 0
        obj.def.rf_links.rf_types{ip} = [];
        obj.def.rf_links.rf_directions{ip} = [];
        obj.def.rf_links.(prop) = [];
    end %if
end %function