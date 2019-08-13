function outdata = fromJson(indata)
    % outdata = mdf.toJson(indata)
    %
    % convert json to matlab structure
    %

    % we need to get the configuration object
    omdf = mdf.getInstance();

    % convert according
    switch (omdf.WHICH_JSON)
        case 'MATLAB'
            outdata = jsondecode(indata);
        case 'JSONLAB'
            outdata = loadjson(indata);
        otherwise
            throw(MException('mdf:fromJson',...
                ['1: invalid json library!!!']));
    end %switch    

end %function
