function res = unload(indata)
    % function res = mdfObj.unload(indata)
    %
    % unload object from memory
    %
    % input:
    %   indata = single string containg uuid or full mdfObj to be deleted
    %
    % output 
    %   res = 1 if successful, 0 otherwise
    
    % initialize output value
    res = false;
    
    % get mdfManage object
    om = mdfManage.getInstance();

    % check input parameter
    switch class(indata)
        case 'char'
            % we got uuid
            uuid = indata;
            obj = om.get(uuid);
        case 'mdfObj'
            % we got an mdfObj
            uuid = indata.uuid;
            obj = indata;
        otherwise
            % option not recognized
            throw(MException('mdfObj.unload','Invalid input. Must be uuid or mdfObj object.'));
    end %switch
    
    % remove object from mdfManage
    res = om.remove(uuid);
    
    % delete object from memory
    if isvalid(obj) && isa(obj,'mdfObj')
        delete(obj);
        res = res && true;
    end %if
    
end %function
