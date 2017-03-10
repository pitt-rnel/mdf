function res = sDelete(obj,indata)
    % function res = obj.sDelete(indata)
    %
    % remove requested objects from specified habitats
    %
    % 
    % input
    % - indata : (cell of structs)
    %            each cell is a struct with the folloing fields
    %            * habuuid = (string) uuid of the habitats to interact with
    %            * selector = (string or ?) information needed by the habitat to save the data
    %                     Examples for some connectors:
    %                     - mdf_mongdb: object uuid
    %                     - mdf_yaml, mdf_mat, mdf_json: file path
    %
    %
   
    res = 0

    % check if indata is a cell, if not make it a cell
    if ~iscell(indata)
        indata = {indata}
    end %if

    % loops on all the save operation
    for i1 = 1:length(indata)
        % 
        % get habitat object
        ohab = obj.getH(indata{i1}.habuuid);

        %
        % check if habitat accept this mode
        if ~ohab.checkMode(obj.mode)
            continue;
        end %if

        %
        % run save on the habitat
        res = res + ohab.sDelete(indata{i1}.selector);
        
    end %for  

end %function sDelete
