function outdata = fromJson(indata)
    % outdata = mdf.toJson(indata)
    %
    % convert json to matlab structure
    %

    % we need to get the configuration object
    oc = mdfConf.getInstance(); 

    % convert according
    switch (oc.getConstant('MDF_JSONAPI'))
        case 'MATLAB'
            outdata = jsondecode(indata);
        case 'JSONLAB'
            outdata = loadjson(indata);
    end %switch    

end %function
