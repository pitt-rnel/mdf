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
    % - parents: (mdfObj) parent(s) requested
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
        uuids = {obj.mdf_def.mdf_parents.mdf_uuid};
        indexes = find(strcmp(uuids,selector));
       
    elseif isstruct(selector)
        % selector is astruct, we pass it to the query method and see what
        % we get back

        % now we are ready to build the json query
        query = mdfDB.prepQuery(selector);
        % retrieve handle to database object
        odb = mdfDB.getInstance();
        % runs query and hopes for the best
        mdf_data = odb.find(query);
        % extract uuids
        selUuids = cellfun(@(item)(item.mdf_def.mdf_uuid),mdf_data,'UniformOutput',0)';
        clear mdf_data;

        % get parents uuid
        uuids = {obj.mdf_def.mdf_parents.mdf_uuid};
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
        if ~isempty(index) && index>=1 && index <=length(obj.mdf_def.mdf_parents)
            % get child uuid 
            uuid = obj.mdf_def.mdf_parents(index).mdf_uuid;
            % get object from memory
            parent = mdfObj.load(uuid);
            % if valid object, insert it in output values
            if ~isempty(parent)
                parents = [parents parent];
            end %if
        end %if
    end %for
end %function
