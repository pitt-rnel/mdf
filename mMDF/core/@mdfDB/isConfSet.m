function res = isConfSet(obj)
    % function res = obj.isConfSet()
    %
    % output
    %  res = (boolean) True if the configuration is properly set, false
    %        otherwise
    %
    %
    
    res = false;
    if isa(obj.host,'char') && ~isempty(obj.host) && ...
            isa(obj.port,'numeric') && ~isempty(obj.port) && ...
            isa(obj.database,'char') && ~isempty(obj.database) && ...
            isa(obj.collection,'char') && ~isempty(obj.collection)
        res = true;
    end %if

end %function