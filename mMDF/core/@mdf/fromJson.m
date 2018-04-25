indata = function fromJson(outdata)
    % indata = mdf.toJson(outdata)
    %
    % convert json to matlab structure
    %

    % we need to get the configuration object
    oc = mdfConf.getInstance(); 

    % convert according
    switch (oc.getConstant(obj,'MDF_JSONAPI'))
        case 'MATLAB'
            outdata = jsondecode(indata);
        case 'JSONLAB'
            outdata = loadjson(indata);
    end %switch    

end %function
