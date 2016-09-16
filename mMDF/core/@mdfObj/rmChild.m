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
%         if isa(child,'mdfObj')
%             uuid = child.uuid;
%             ochild = child;
%         elseif isa(child,'char')
%             uuid = child;
%             ochild = mdfObj.load(uuid);
%         else
%            throw(MException('mdfObj:rmChild','Invalid children property type.')); 
%         end %if
        % find child in list
        pos = find(strcmp(obj.mdf_def.mdf_children.(prop).mdf_uuid,uuid));
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
        % make sure that child has parent link removed
        % mutual relationship is removed by static property of the mdf class
        %ochild.rmParent(obj.uuid);
    else
        % all children under prop need to be removed
        %for i = 1:length(obj.mdf_def.mdf_children.(prop))
            % get child object and remove parent link
        %    ochild = mdfObj.load(obj.mdf_def.mdf_children.(prop)(i).uuid);
            % mutual relationship is removed by static property of the mdf
            % class
            %ochild.rmParent(obj.uuid);
        %end %for
        % reset property
        % remove all the links and leave property empty
        obj.mdf_def.mdf_children.(prop) = [];
        % reset property type
        obj.mdf_def.mdf_children.mdf_type{ip} = [];
    end %if
end %function