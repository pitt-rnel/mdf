function res = remove(obj)
    % function res = obj.remove()
    %
    % remove object, aka delete the object from this data collection. 
    % That includes files and db document
    %
    
    % initialize output value
    res = 0;
    
    % get db and manage singleton
    odb = mdfDB.getInstance();
    % get mdfManage object
    om = mdfManage.getInstance();
    
    % remove mat file
    dFile = obj.getDataFileName(true);
    delete(dFile);
    
    % remove yml file
    mdFile = obj.getMetadataFileName(true);
    delete(mdFile);
    
    % remove db record
    uuid = obj.uuid;
    query = ['{ "mdf_def.mdf_uuid" : "' uuid '" }'];
    odb.remove(query);
    
    % remove object from mdfManage
    res = om.remove(uuid);
    
    % delete object from memory
    if isvalid(obj) && isa(obj,'mdfObj')
        delete(obj);
    else
        res = 0;
    end %if

end %function
