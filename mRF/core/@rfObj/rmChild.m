function res = rmChild(obj, prop, child)
    % function res = obj.rmChild(obj, prop, child)
    %
    % remove specific child or all children under prop
    %
    % input:
    % - prop  : (string) name of the child property
    % - child : (string or rfObj) child to be removed. Optional
    %           if no child is provided, all the children under prop will
    %           be removed
    %
    
    res = obj;
    
    if nargin < 2
        throw(MException('rfObj:rmChild','Invalid number of arguments'));
    end %if
    
    % check if prop exists
    ip = find(strcmp(obj.def.rf_children.rf_fields,prop));
    if ~isfield(obj.def.rf_children,prop) || isempty(ip)
        throw(MException('rfObj:rmChild','Invalid prop name or object corrupted'));
    end %if
    
    % check if we got child or we need to remove everything
    if nargin >= 3
        % single child to be removed
        %
        % get uuid from child
        if isa(child,'rfObj')
            uuid = child.uuid;
            ochild = child;
        elseif isa(child,'char')
            uuid = child;
            ochild = rfObj.load(uuid);
        else
           throw(MException('rfObj:rmChild','Invalid children property type.')); 
        end %if
        % find child in list
        pos = find(strcmp(obj.def.rf_children.(prop).rf_uuid,uuid));
        if isempty(pos)
           throw(MException('rfObj:rmChild','Child uuid not found in children property.')); 
        end %if
        % remove child from all the lists
        obj.def.rf_children.(prop)(pos) = [];
        if length(obj.def.rf_children.(prop)) == 0
            obj.def.rf_children.rf_types{ip} = [];
            obj.def.rf_children.(prop) = [];
        end %if
        % make sure that child has parent link removed
        % mutual relationship is removed by static property of the rf class
        %ochild.rmParent(obj.uuid);
    else
        % all children under prop need to be removed
        for i = 1:length(obj.def.rf_children.(prop))
            % get child object and remove parent link
            ochild = rfObj.load(obj.def.rf_children.(prop)(i).uuid);
            % mutual relationship is removed by static property of the rf
            % class
            %ochild.rmParent(obj.uuid);
        end %for
        % reset property
        obj.def.rf_children.(prop) = [];
        obj.def.rf_children.rf_type{ip} = [];
    end %if
end %function