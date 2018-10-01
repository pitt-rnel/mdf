function obj = fromJson(jsonString)
    % function obj = fromJson(jsonString)
    %
    % create an mdf object and populates it using the json string passed
    % in input
    %
    % input
    % - (string) jsonString: string containing the json format of the
    %                        object
    %
    % output
    % - (mdfObj) obj: mdf object fully populated
    %
    
    %
    % instantiate new mdfObj
    obj = mdfObj();
    %
    % convert json string to matlab structure
    jsonStruct = mdf.fromJson(jsonString);
    %
    % use populate to populate the object
    res = obj.populate(jsonStruct);
    
end %function