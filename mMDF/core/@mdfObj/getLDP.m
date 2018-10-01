function res = ldp(obj)
    % function res = obj.ldp()
    %
    % return the list of the data properties that this object has
    % this function is a place mark for listDataProperties
    %
    % output:
    % - res : cell array with the name of the data properties
    %
    %
    
    % return the list of the data properties tdirectly from the internal
    % structure of the object
    res = obj.getListDataProperties();
    
end %function