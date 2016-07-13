function outstring = sfilter(instring)
    % function outstring = mdfConf.sfilter(instring)
    %
    % filter constants in the instring. Aka substitute constants name
    % with their value
    % Static version of the method filter. It takes care of retrieving the
    % object and call the methods
    %
    % Input
    % - instring: input string containing constants references
    %
    % Output
    % - outstring: output string where the constants references have been
    %              substituted with their values
    %
    
    % retrieve mdfconf object
    omdfc = mdfConf.getInstance();
    
    % call filter method on object
    outstring = omdfc.filter(instring);
    
end %function