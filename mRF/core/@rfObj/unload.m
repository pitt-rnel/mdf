function res = unload(indata)
    % function res = rfObj.unload(indata)
    %
    % unload object from memory
    %
    % input:
    %   indata = single string containg uuid or full rfObj to be deleted
    %
    % output 
    %   res = 1 if successful, 0 otherwise
    
    % get rfManage object
    om = rfManage.getInstance();

    % check input parameter
    switch class(indata)
        case 'char'
            % we got uuid
            uuid = indata;
            obj = om.get(uuid);
        case 'rfObj'
            % we got an rfObj
            uuid = indata.uuid;
            obj = indata;
        otherwise
            % option not recognized
            throw(MException('rfObj.unload','Invalid input. Must be uuid or rfObj object.'));
    end %switch
    
    
    % remove object from rfManage
    res = om.remove(uuid);
    
    % delete object from memory
    if isvalid(obj) && isa(obj,'rfObj')
        delete(obj);
    else
        res = 0;
    end %if
    
end %function