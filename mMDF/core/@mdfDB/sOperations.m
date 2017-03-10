function res = sOperations(obj,indata)
    % function res = obj.sOperations(indata)
    %
    % run specific operations on the habitats
    %
    % input
    % - indata: (cell array of struct)
    %           each cell should have the following fields
    %           * habuuid: (string) habitat uuid where the operation should be run
    %           * operation: (string) name of the function that correspond to the operation
    %           * arguments: (cell array) arguments to be passed to the operation function
    %    
    %
    % output
    % - res: 0 if no results have been found
    %        cell of results from each operation
    %

    res = 0;

    % makes sure that indata is a cell array
    if ~iscell(indata)
        indata = {indata};
    end %if
 
    % temporary place holder for results
    res = {};

    % loops on all the blind queries
    for i1 = 1:length(indata)

        % gets habitat object
        ohab = obj.getH(indata(i1).habuuid);
        %   
        % call habitat method
        res{end+1} = ohab.(indata(i1).operation)(indata(i1).arguments{:});
 
    end %for
    
end %function
