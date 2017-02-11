function outdata = loadMdfData(indata)
    % static funtion outdata = mdfObj.loadMdfData(indata)
    %
    % return a matlab struct with the mdf object structure ready to be
    % injected in a mdf object
    % returns empty is it cannot load
    %
    % input
    % - indata: (string) string containing uuid, filename, json or mongo
    %           query
    %
    % output
    % - outdata: (struct) matlab struct containing mdf object data structure
    %
    
    % initialize output
    outdata = [];
    
    % first let's assume that we have a uuid
    % first check if we really have a possible uuid
    if regexp(lower(indata),'[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}') == 1
        % checks if the object is already loaded in memory
        outdata = om.get(indata.uuid);
        if ~isempty(outdata)
            % object already loaded
            % return back the object in memory
            return;
        end %if
        try
            % load object by uuid
            mdf_data = odb.find(['{ "mdf_def.mdf_uuid" : "' indata '" }']);
        catch
            mdf_data = [];
        end %try/catch
    end%if
    % if did not find anything assuming that the string was a uuid,
    % we assume that is a file name
    if isempty(mdf_data)
        try
            mdf_data = mdfObj.fileLoadInfo(indata);
        catch
            mdf_data = [];
        end %try/catch
    end %if
    % if we have not found anything yet,
    % we assume that is a json string
    if isempty(mdf_data)
        try
            mdf_data = loadjson(indata);
        catch
            mdf_data = [];
        end %try/catch
    end %if
    % no results yet, we assume that it's a mongo query
    if isempty(mdf_data)
        try
            mdf_data = odb.find(indata);
        catch
            mdf_data = [];
        end %try/catch
    end %if
end %function