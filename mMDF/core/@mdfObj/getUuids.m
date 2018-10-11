function outdata = getUuids(obj,group,property,format)
    % function outdata = obj.getUuids(group,property, format)
    %
    % this function returns the list of uuids of the object in the
    % specified group of relationship: parents, children, links
    % this function uses only local information. it will not load any of
    % the object specified in the relationship
    %
    % input:
    %  - group: (string) group for which we would like to uuids
    %           There is no default for this
    %           Possible values:
    %           * children,child,c
    %               returns uuids for all the children objects
    %           * links,l
    %               returns uuids for all the objects linked to the this one
    %           * unidirectionallinks, unilinks, ulinks, ul
    %               returns uuids for all the objects unidirectionally
    %               linked from the current one
    %           * bidirectionallinks, bilinks, blinks, bl
    %               returns uuids for all the objects bidirectionally
    %               linked to the current one
    %           * parents, p
    %               returns uuids of all the parents
    %
    %  - property: (string) name of the property within the group that we
    %               would like to retrieve.
    %               If not specified, will return all properties within the
    %               group
    %               Not used for parents
    %
    %  - format: (string) type of output
    %            Possible values:
    %            * default, uuids = output is a cell array containing uuids
    %            * UuidWithPropName = structure with uuid and property
    %                     associated
    %            * UuidWithPropNameNoEmpty = structure with uuid and
    %                     property name, no empty is retruned
    %
    % output:
    %  - outdata: (cell array of strings or array of structs)
    %             list of uuids requested or uuids and property to access
    %             them
    %
    
    % check if group is a struct
    if isstruct(group)
        % we assume that the userr passed in a struct
        % extract fields
        property = 'all';
        if isfield(group,'property')
            property = group.property;
        end %if
        format = 'uuids';
        if isfield(group,'format')
            format = group.format;
        end %if
        group = group.group;
    else
        if nargin < 3
            % we got only group
            property = 'all';
        end %if
        if nargin < 4
            % we did not get 
            format = 'uuids';
        end %if
    end %if
    % initialize uuid list and property list
    ul = {};
    pl = {};
    
    % check input parameters
    switch group
        case {'children','child','c'}
            fg = 'c';
        case {'links', 'l'}
            fg = 'l';
        case {'unidirectionallinks', 'unilinks', 'ulinks', 'ul'}
            fg = 'ul';
        case {'bidirectionalinks', 'bilinks', 'blinks', 'bl'}
            fg = 'bl';
        case {'parents', 'p'}
            fg = 'p';
        otherwise
             % error
            throw( ...
                MException( ...
                    'mdfObj:getUuids', ...
                    'Invalid group option.'));
            return;
    end %switch           
            
    % check input parameters
    switch fg
        case {'c'}
            % check if we got a property or not
            if ~isempty(property)
                if isfield(obj.mdf_def.mdf_children,property)
                    % extract array of references
                    temp = obj.mdf_def.mdf_children.(property);
                    % set lists
                    ul = {temp(:).mdf_uuid}';
                    pl = cell(size(ul));
                    pl(:) = {property};
                elseif strcmpi(property,'all')
                    % cycle on all the properties
                    for i = 1:length(obj.mdf_def.mdf_children.mdf_fields)
                        % get field names
                        pn = obj.mdf_def.mdf_children.mdf_fields{i};
                        % extract array of references
                        temp = obj.mdf_def.mdf_children.(pn);
                        % set lists
                        ult = {temp(:).mdf_uuid}';
                        plt = cell(size(ult));
                        plt(:) = {pn};
                        % append values in complete list
                        ul = [ ul, ult];
                        pl = [ pl, plt];
                    end %for
                end %if
            end %if
            
        case {'l', 'ul', 'bl'}
            % check if we got a property or not
            if ~isempty(property)
                % initialize the directionality list
                % even if link directionality is defined at the property
                % level, we transfer the directionality to each entry, so
                % we can select afterward all the links with the selected
                % directionality
                dl = {};
                if isfield(obj.mdf_def.mdf_links,property)
                    % extract array of references
                    temp = obj.mdf_def.mdf_links.(property);
                    % set lists
                    ul = {temp(:).mdf_uuid}';
                    pl = cell(size(ul));
                    pl(:) = {property};
                    dl = {temp(:).mdf_direction}';
                elseif strcmpi(property,'all')
                    % cycle on all the properties
                    for i = 1:length(obj.mdf_def.mdf_links.mdf_fields)
                        % get field names
                        pn = obj.mdf_def.mdf_links.mdf_fields{i};
                        % extract array of references
                        temp = obj.mdf_def.mdf_links.(pn);
                        % set lists
                        ult = {temp(:).mdf_uuid}';
                        plt = cell(size(ult));
                        plt(:) = {pn};
                        dlt = {temp(:).mdf_direction}';
                        % append values in complete list
                        ul = [ ul; ult];
                        pl = [ pl; plt];
                        dl = [ dl; dlt];
                    end %for
                end %if
                % filters accordingly to the request
                mask = ones(size(ul));
                switch fg
                    case 'ul'
                        % retains only the unidirectional links
                        mask = strcmp('u',dl);
                    case 'bl'
                        % retains only bidirectional links
                        mask = strcmp('b',dl);
                end %switch
                ul(~mask) = [];
                pl(~mask) = [];
            end %if

        case {'parents', 'p'}
            % extract array of references
            temp = obj.mdf_def.mdf_parents;
            % set lists
            if length(temp) > 0
                ul = {temp(:).mdf_uuid}';
            end %if
          
        otherwise
            % error
            throw( ...
                MException( ...
                    'mdfObj:getUuids', ...
                    'Invalid group option.'));
            return;
    end %switch
    
    % prepare output according to format requested
    switch (format)
        case 'UuidWithPropName'
            % initialize outdata
            outdata = struct( ...
                'uuid', ul, ...
                'prop', pl);
        case 'UuidWithPropNameNoEmpty'
            % initialize outdata
            outdata = [];
            if ~isempty(ul)
                outdata = struct( ...
                    'uuid', ul, ...
                    'prop', pl);            
            end %if
        otherwise
            % returns only uuids
            outdata = ul;
    end %switch
end %function