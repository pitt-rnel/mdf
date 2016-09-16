function res = rmParentChildRelation(parent,child,prop)
    % function res = rmParentChildRelation(parent,child,prop)
    %
    % remove a parent-child relationship between object parent and child.
    % in parent object, child should be accessible under the property prop
    %
    % INPUT
    % - parent : (uuid or mdfObj) parent object or uuid of the parent object
    % - child  : (uuid or mdfObj) child objecy or uuid of the child object
    % - prop   : (string) property under which the child object will be
    %            found in the parent object
    
%     oParent = [];
%     uParent = [];
%     if ischar(parent)
%         % we got uuid for parent object
%         % load object
%         uParent = parent;
%         oParent = mdfObj.load(uParent);
%         
%     elseif isa(parent,'mdfObj')
%         % we got parent object
%         % extract uuid
%         oParent = parent;
%         uParent = parent.uuid;
%         
%     end %if
%     % check thay parent obejct and uuid are valid
%     if isempty(oParent) || isempty(uParent)
%         throw( ...
%             MException( ...
%                 'mdf:addParentChildRelation', ...
%                 'Invalid Parent object'));
%     end %if
    % get parent uuid and object
    [uParent, oParent] = mdf.getUAO(parent);
    % check that property on parent object is valid
    if ~any(strcmp(oParent.mdf_def.mdf_children.mdf_fields,prop))
        throw( ...
            MException( ...
                'mdf:addParentChildRelation', ...
                'Invalid Parent property'));
    end %if
    
%     oChild = [];
%     uChild = [];
%     if ischar(child)
%         % we got uuid for parent object
%         % load object
%         uChild = child;
%         oChild = mdfObj.load(uChild);
%         
%     elseif isa(child,'mdfObj')
%         % we got parent object
%         % extract uuid
%         oChild = child;
%         uChild = child.uuid;
%         
%     end %if
%     if isempty(oChild) || isempty(uChild)
%         throw( ...
%             MException( ...
%                 'mdf:addParentChildRelation', ...
%                 'Invalid Parent object'));
%     end %if
    % get child uuid and object 
    [uChild, oChild] = mdf.getUAO(child);
    % add child under designated property in parent
    res = oParent.rmChild(prop,oChild);
    
    % add parent under parent property in child object
    res = oChild.rmParent(oParent);
    
end %function
