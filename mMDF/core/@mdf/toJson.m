function outdata = toJson(indata)
    % outdata = mdf.toJson(indata)
    %
    % convert matlab structure to json
    %
    omdf = mdf.getInstance();

    % convert according
    switch (omdf.WHICH_JSON)
        case 'MATLAB'
            outdata = jsonencode(indata);
        case 'JSONLAB'
            outdata = savejson('',indata);
        otherwise
            throw(MException('mdf:toJson',...
                ['1: invalid json library!!!']));
    end %switch    

end %function
