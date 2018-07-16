function outdata = toJson(indata)
    % outdata = mdf.toJson(indata)
    %
    % convert matlab structure to json
    %

    % we need to get the configuration object
    oc = mdfConf.getInstance(); 

    % convert according
    switch (oc.getConstant('MDF_JSONAPI'))
        case 'MATLAB'
            outdata = jsonencode(indata);
        case 'JSONLAB'
            outdata = savejson('',indata);
    end %switch    

end %function
