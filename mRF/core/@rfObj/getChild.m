function children = getChild(obj, prop, selector)
    % function child = obj.getChild(prop, selector)
    %
    % return the object child of type prop accordign to the selector
    %
    % Input
    % - prop: (string) children property where we are looking for our child
    % - selector: value used to select requested child
    %      options
    %      * numeric: index of the child within the property array of
    %                 objects
    %      * string: uuid of the child 
    %      * struct: query structure to find child
    %
    % Output
    % - children: (rfObj) child(ren) requested
    %
    
    % initialize output value
    children = [];
    
    % check if children property exists and is valid
    if ~any(strcmp(obj.def.rf_children.rf_fields,prop))
        % invalid child property requested
        return
    end %if
    
    % initialize index child object
    i = [];
    % find which child needs to be returned
    if isnumeric(selector)
        % use selector a child index
        indexes = selector;
        
    elseif ischar(selector)
        % selector is a string, we assume it is the child uuid
        % find index of the object with this uuid
        uuids = {obj.def.rf_children.(prop).uuid};
        indexes = find(strcmp(uuids,selector));
       
    elseif isstruct(selector)
        % selctor is astruct, we pass it to the query method and see what
        % we get back

        % now we are ready to build the json query
        query = rfDB.prepQuery(selector);
        % runs query and hopes for the best
        rf_data = odb.find(query);
        % extract uuids
        selUuids = {rf_data.rf_def.rf_uuid};
        clear rf_data;

        % get uuids of the children
        uuids = {obj.def.rf_children.(prop).uuid};
        % get index of objects
        for j=1:length(selUuids)
            i2 = find(strcmp(uuids,selUuids{j}));
            if ~isempty(i2)
                indexes = [indexes i2];
            end %if
        end %for
        clear selUuids;
    else
        % invalid selector
        return;
    end %if
    
    % find child object to be returned
    for i=1:length(indexes)
        % get index
        index = indexes(i);
        % check if it is a valide index
        if ~isempty(index) && index>=1 && index <=length(obj.def.rf_children.(prop))
            % get child uuid 
            uuid = obj.def.rf_children.(prop)(index).uuid;
            % get object from memory
            child = rfObj.load(uuid);
            % if valid object, insert it in output values
            if ~isempty(child)
                children = [children child];
            end %if
        end %if
    end %for
end %function