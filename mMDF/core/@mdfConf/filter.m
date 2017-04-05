function outstring = filter(obj,instring)
    % function outstring = filter(obj,instring)
    %
    % find and substitute constants in the string
    % Constants can be embedded in any string enclosed in <>
    % 
    % input
    % - instring: [char] input string
    %
    % output
    % - outstring: [char] output string with constants substituted with
    %              their values
    %
    
    % define constants pattern
    cp = '<[A-Z][A-Z_]+>';
    
    % find all the instances of constants
    [ib,ie] = regexp(instring,cp);
    
    % set output value
    outstring = instring;
    
    % get constants
    C = obj.getC();
    
    % loop on the findings and try to substitute them
    for i = 1:length(ib)
        % extract pattern found and constant name
        pf = instring(ib(i):ie(i));
        cn = instring(ib(i)+1:ie(i)-1);
        
        % check if constant exists
        if isfield(C,cn)
            % constant found
            
            % substitute in output string
            outstring = regexprep(outstring,pf,C.(cn));
        end %if
        
    end %for

end %function