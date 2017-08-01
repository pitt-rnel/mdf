function res = rmChild(obj, prop, child)
    % function res = obj.rmChild(obj, prop, child)
    %
    % remove specific child or all children under prop
    %
    % input:
    % - prop  : (string) name of the child property
    % - child : (string or mdfObj) child to be removed. Optional
    %           if no child is provided, all the children under prop will
    %           be removed
    %
    
    res = obj;
    
    if nargin < 2
        throw(MException('mdfObj:rmChild','Invalid number of arguments'));
    end %if
    
    % check if prop exists
    ip = find(strcmp(obj.mdf_def.mdf_children.mdf_fields,prop));
    if ~isfield(obj.mdf_def.mdf_children,prop) || isempty(ip)
        throw(MException('mdfObj:rmChild','Invalid prop name or object corrupted'));
    end %if
    
    % check if we got child or we need to remove everything
    if nargin >= 3
        % single child to be removed
        %
        % get uuid from child
        [uuid, ochild] = mdf.getUAO(child);
        %
        % find child in list
        pos = find(strcmp({obj.mdf_def.mdf_children.(prop).mdf_uuid},uuid));
        if isempty(pos)
           throw(MException('mdfObj:rmChild','Child uuid not found in children property.')); 
        end %if
        % remove child from all the lists
        % remove requested child from property list
        obj.mdf_def.mdf_children.(prop)(pos) = [];
        % check if the list is now empty
        if length(obj.mdf_def.mdf_children.(prop)) == 0
            % reset property type
            obj.mdf_def.mdf_children.mdf_types{ip} = [];
            % reset property type, remove structure
            obj.mdf_def.mdf_children.(prop) = [];
        end %if
    else
        % reset property
        % remove all the links and leave property empty
        obj.mdf_def.mdf_children.(prop) = [];
        % reset property type
        obj.mdf_def.mdf_children.mdf_type{ip} = [];
    end %if
    
    % check if we need to remove the children 
    % if it is empty, we do
    if length(obj.mdf_def.mdf_children.(prop)) == 0
        % remove associated type
        obj.mdf_def.mdf_children.mdf_types(ip) = [];
        % remove field name from list
        obj.mdf_def.mdf_children.mdf_fields(ip) = [];
        % remove property
        obj.mdf_def.mdf_children = rmfield(obj.mdf_def.mdf_children,prop);
        
    end %if
end %function