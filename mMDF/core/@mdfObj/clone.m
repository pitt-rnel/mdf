function res = clone(obj)
    % function res = obj.clone()
    %
    % clone the current object, creating a new one with a new uuid
    % files, relationships are not copied to cloned object
    %
    % output:
    % - res : new object if successful, [] if not
    %
    %
    
    % create a new mdfObj and populate it
    res = mdfObj();
    res.type = obj.type;
    res.uuid = mdf.UUID();
    res.metadata = obj.metadata;
    % get data properties
    dpl = obj.getListDataProperties();
    for i = 1:length(dpl)
        % get data property name
        dp = dpl{i};
        % load data in source object
        obj.dataLoad(dp);
        % transfer data property calling directly subsasgn on target object
        % otherwise matlab does not call the object method
        res.subsasgn( ...
            struct( ...
                'type', { '.', '.' }, ...
                'subs', { 'data', dp } ), ...
            obj.data.(dp) );
        % updates property definition in new object
        res.setDataInfo(dp);
        % marked as loaded
        res.status.loaded.data.(dp) = 1;
    end %for
    
end %function
