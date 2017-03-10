function res = query(obj,indata)
    % function res = obj.query(indata)
    %
    % run queries on the specified habitat. If habitat is not specified, 
    % it will try to run the query on all the habitats
    %
    % input
    % - indata : (cell of structs)
    %            each cell is a struct with the folloing fields
    %            * habuuid = (string) uuid of the habitats to interact with
    %                        if this field is not specified, mdfDB will try on every habitat
    %            * query = (struct or string) structure or serialize structure with query 
    %                      for the specific habitat
    %                     - mdf_mongdb: object uuid, query struct or json query
    %                     - mdf_yaml, mdf_mat, mdf_json: file path
    %
    %

    res = {};

    % check if we got a cell array in input
    if ~iscell(indata)
       indata = {indata};
    end %if

    % loops on all the query in input
    for i1 = 1:length(indata)

        % check if habitat is specified
        if isfield(indata{i1},'habuuid')
           % runs query on specified habitat
           key = ['uuid_' indata{i1}.habuuid;
           res{i1} = obj.habitats.(key).query(indata{i1}.query);
        else
 
        end %if

    end %for
end %function find
