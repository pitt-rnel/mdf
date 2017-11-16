function C = getCollCont(obj,collid,contid)
    % C = mdfConf.getCollCont(obj,collid,contid)
    %
    % return the selected container configured within the collection
    %
    % output
    %   C = (struct) collection
    % input
    %   obj = this object
    %   collid = (string,integer) human or machine name or index of the
    %            collection requested
    %   contid = (string,integer) human or machine name or index of the
    %            container requested
    %
    
    % set collection selection from input
    collSel = obj.getCollectionIndex(collid);
    % set container selection from input
    contSel = obj.getContainerIndex(contid);

    % initialize output structure
    C = struct;
    % check if we have a selection defined
    if ~isempty(collSel) && isnumeric(collSel) && ~isnan(collSel)
        % extract selected configuration
        collC = obj.confData.collections.collection{collSel};
        % extract selected container
        contC = obj.confData.containers.container{contSel};
        % check if the container is configured within the collection
        if ismember( ...
                contC.uuid, ...
                cellfun(@(item) item.uuid, collC.containers.container, 'UniformOutput',0))
            C = contC;
        end %if
    end %if
    
end %function

