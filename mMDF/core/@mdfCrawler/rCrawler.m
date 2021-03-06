function res = rcrawler(obj,startObj)
    % function res = obj.rcrawler(startObj)
    %
    % crawls from the start object and build the list of objects and the
    % relation between them
    %
    % Input
    %   startObj = (string) UUID of the mdfObj to start from
    %              (mdfObj) object to start from
    %
    % Output
    %   res = return status.
    %
    
    % initialize current object and all the lists
    obj.sobj = [];
    obj.objList = struct();
    obj.relList = struct( ...
        'hash',[], ...
        'relation', [], ...
        'source', [], ...
        'dest', [], ...
        'sProp', [], ...
        'dProp', [] );
    obj.hList = {};
    
    
    % get object
    if ischar(startObj)
        % indata contains the uuid of the object we need start from
        obj.sobj = startObj;
    elseif isa(startObj,'mdfObj')
        % indata contains the mdf object that we need to start from
        obj.sobj = startObj.uuid;
    else
        raise( ...
            MException( ...
                'mdfCrawler:rcrawler', ...
                '10: Invalid type for input argument.'));
    end %if
    
    % check that we have only one object
    if ~ischar(obj.sobj) && length(obj.sobj) ~= 1
        raise( ...
            MException( ...
                'mdfCrawler:rcrawler', ...
                '20: No object or more than one object found.'));
    end %if
    
    % build the new lists outdata
    res = obj.irCrawler(obj.sobj);
    
end %function
