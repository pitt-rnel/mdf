function res = clone(obj)
    % function res = obj.clone()
    %
    % clone the current object, creating a new one with a new uuid
    %
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
    dpl = obj.listDataProperties();
    for i = 1:length(dpl)
        dp = dpl{i};
        res.data.(dp) = obj.data.(dp);
    end %for
    
end %function
