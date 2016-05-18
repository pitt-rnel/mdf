function res = addParentChildRelation(parent,child,prop)
    % function res = addParentChildRelation(parent,child,prop)
    %
    % create a parent-child relationship between object parent and child.
    % in parent object, child will be accessible under the property prop
    %
    % INPUT
    % - parent : (uuid or rfObj) parent object or uuid of the parent object
    % - child  : (uuid or rfObj) child objecy or uuid of the child object
    % - prop   : (string) property under which the child object will be
    %            found in the parent object
    
    oParent = [];
    uParent = [];
    if ischar(parent)
        % we got uuid for parent object
        % load object
        uParent = parent;
        oParent = rfObj.load(uParent);
        
    elseif isa(parent,'rfObj')
        % we got parent object
        % extract uuid
        oParent = parent;
        uParent = parent.uuid;
        
    end %if
    if isempty(oParent) || isempty(uParent)
        throw( ...
            MException( ...
                'rf:addParentChildRelation', ...
                'Invalid Parent object'));
    end %if

    oChild = [];
    uChild = [];
    if ischar(child)
        % we got uuid for parent object
        % load object
        uChild = child;
        oChild = rfObj.load(uChild);
        
    elseif isa(child,'rfObj')
        % we got parent object
        % extract uuid
        oChild = child;
        uChild = child.uuid;
        
    end %if
    if isempty(oChild) || isempty(uChild)
        throw( ...
            MException( ...
                'rf:addParentChildRelation', ...
                'Invalid Parent object'));
    end %if
%     if ~any(strcmp(oParent.def.rf_children.rf_fields,prop))
%         throw( ...
%             MException( ...
%                 'rf:addParentChildRelation', ...
%                 'Invalid Parent property'));
%     end %if
    
    % add child under designated property in parent
    res = oParent.addChild(prop,oChild);
    
    % add parent under parent property in child object
    res = oChild.addParent(oParent);
    
end %function