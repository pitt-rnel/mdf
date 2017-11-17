function res = setContSel(obj)
    % function res = setContSel(obj)
    %
    % internal function to update container selection property
    %

    res = 0;

    % loops through collections
    uuids = {};
    for i = 1:length(obj.menu.collections)
        % check if it is selected
        if obj.menu.collections(i).selected
            i = obj.getCollectionIndex(obj.menu.collections(i).uuid);
            uuids{end+1} = cellfun( ...
                @(x) x.uuid, ...
                obj.confData.collections.collection{i}.containers.container, ...
                'UniformOutput',0);
        end %if          
    end %for    

    uuids = unique([uuids{:}]);

    % reset containers
    if ~isempty(uuids)
        for i = 1:length(obj.menu.containers)
            obj.menu.containers(i).selected = any(ismember(obj.menu.containers(i).uuid,uuids));
        end %for
    end %if

    res = 1;
end %function
