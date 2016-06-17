function res = rmLink(obj, prop, link)
    % function res = obj.rmLink(obj, prop, link)
    %
    % remove specific link or all links under prop
    %
    % input:
    % - prop  : (string) name of the link property
    % - link : (string or mdfObj) link to be removed. Optional
    %           if no link is provided, all the links under prop will
    %           be removed
    %
    
    res = obj;
    
    if nargin < 2
        throw(MException('mdfObj:rmLink','Invalid number of arguments'));
    end %if
    
    % check if prop exists
    ip = find(strcmp(obj.mdf_def.mdf_links.mdf_fields,prop));
    if ~isfield(obj.mdf_def.mdf_links,prop) || isempty(ip)
        throw(MException('mdfObj:rmLink','Invalid prop name or object corrupted'));
    end %if
    
    % check if we got link or we need to remove everything
    if nargin >= 3
        % single link to be removed
        %
        % get uuid from link
        if isa(link,'mdfObj')
            uuid = link.uuid;
            olink = link;
        elseif isa(link,'char')
            uuid = link;
            olink = mdfObj.load(uuid);
        else
           throw(MException('mdfObj:rmLink','Invalid links property type.')); 
        end %if
        % find link in list
        pos = find(strcmp(obj.mdf_def.mdf_links.(prop).mdf_uuid,uuid));
        if isempty(pos)
           throw(MException('mdfObj:rmLink','Link uuid not found in links property.')); 
        end %if
        % remove link from all the lists
        obj.mdf_def.mdf_links.(prop)(pos) = [];
    else
        % reset property
        obj.mdf_def.mdf_links.(prop) = [];
    end %if
    % remove type and directionality if necessary
    if length(obj.mdf_def.mdf_links.(prop)) == 0
        obj.mdf_def.mdf_links.mdf_types{ip} = [];
        obj.mdf_def.mdf_links.mdf_directions{ip} = [];
        obj.mdf_def.mdf_links.(prop) = [];
    end %if
end %function