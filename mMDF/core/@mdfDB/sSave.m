function res = sSave(obj,indata)
    % function res = obj.sSave(indata)
    %
    % save all the payload provided in input syncronously
    %
    % 
    % input
    % - indata : (cell of structs)
    %            each cell is a struct with the folloing fields
    %            * habuuid = (string) uuid of the habitats to interact with
    %            * data = (struct or string) structure or serialize structure to be saved 
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
        res = res + ohab.sSave(indata{i1}.selector,indata{i1}.data);
        
    end %for  

end %function save
