function res = listDataProperties(obj)
    % function res = obj.listDataProperties()
    %
    % return the list of the data properties that this object has
    %
    % output:
    % - res : cell array with the name of the data properties
    %
    %
    
    % return the list of the data properties tdirectly from the internal
    % structure of the object
    res = obj.mdf_def.mdf_data.mdf_fields;
    
end %function