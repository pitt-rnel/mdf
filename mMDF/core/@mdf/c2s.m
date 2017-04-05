function outdata = c2s(indata)
    % function outdata = mdf.c2s(indata)
    %
    % transform a cell array of homogeneus struct in to an a array of
    % struct
    % it is needed and it is useful because conversion from json and yaml
    % to matlab internal data, sometimes structures becomes cell arrays
    %
    % input
    % - indata: cell array of structures equelly defined
    %
    % output
    % - outdata: array of struct containing the same data
    %
    
    outdata = indata;
    if isa(indata,'cell')
        % due to data type conversion, mdf_parents is a cell
        % we want an array of struct
        first = true;
        outdata = [];
        for j = 1:length(indata)
            if first
            	% first iteraction, define new structure
                outdata = indata{j};
                first = false;
            else
            	% sebsequent iteractions, append at the end
                outdata(end+1) = indata{j};
                end %if
            end %for
    end %for
end %function