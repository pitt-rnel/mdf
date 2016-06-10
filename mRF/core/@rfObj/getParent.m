function parents = getParent(obj, selector)
    % function parent = obj.getParent(selector)
    %
    % return the object parent according to the selector
    %
    % Input
    % - selector: value used to select requested parent
    %      options
    %      * numeric: index of the parent within the parents array of
    %                 objects
    %      * string: uuid of the parent
    %      * struct: query structure to find parent
    %
    % Output
    % - parents: (rfObj) parent(s) requested
    %
    
    % initialize output value
    parents = [];
    
    % check if user did not provide any selector
    if nargin < 2
        selector = 1;
    end %if
    
    % initialize index child object
    indexes = [];
    % find which parent needs to be returned
    if isnumeric(selector)
        % use selector a parent index
        indexes = selector;
        
    elseif ischar(selector)
        % selector is a string, we assume it is the parent uuid
        % find index of the object with this uuid
        uuids = {obj.def.rf_parent.rf_uuid};
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

        % get parents uuid
        uuids = {obj.def.rf_parent.rf_uuid};
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
    
    % find parent object to be returned
    for i=1:length(indexes)
        % get index
        index = indexes(i);
        % check if it is a valide index
        if ~isempty(index) && index>=1 && index <=length(obj.def.rf_parents)
            % get child uuid 
            uuid = obj.def.rf_parents(index).rf_uuid;
            % get object from memory
            parent = rfObj.load(uuid);
            % if valid object, insert it in output values
            if ~isempty(parent)
                parents = [parents parent];
            end %if
        end %if
    end %for
end %function