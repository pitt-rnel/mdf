function C = getConstant(obj, environment, constant, error, value)
    % C = obj.getConstant(obj,constant, error, value)
    %
    % return the selected constant in the current configuration
    %
    % output
    %   C = (variable) value of the constant requested
    % input
    %   obj = this object
    %   environment = (string) which evironment we are going to loo for the constant
    %                 requested
    %   constant = (string) selected constant
    %   error = (optional) behaviour on error
    %           Possible values :
    %             - 'exception' : default. throw and exception
    %             - 'empty'     : return empty value on error
    %             - 'nan'       : return NaN on error
    %             - 'minusone'  : return -1 on error
    %             - 'minusinf'  : return -Inf on error
    %             - 'value'     : return value specified in value argument
    %   value = value to pass back if error = 'value'
    %
    
    
    if nargin <= 2
        % we got only the variable name
        % we assume that we are looking on GLOBAL
        constant = environment;
        environment = 'GLOBAL';
    else
        sel = obj.getCollectionIndex(environment);
        if isnan(sel) | ~isnumeric(sel) | isempty(sel)
            environment = 'GLOBAL';
        end %if
    end %if
    
    % check 
	if nargin <= 3
    	error = 'exception';
    end %if
    if nargin <= 4
        default = 'NO-DEFAULT-VALUE';
    end %if
    
    try 
        % get current configuration
        cC = obj.getEnv(environment);
        % get constant
        C = eval(['cC.' constant]);
    catch e
        switch error
            case 'exception'
                rethrow(e);
            case 'empty'
                C = [];
            case 'nan'
                C = NaN;
            case 'minusone'
                C = -1;
            case 'minusinf'
                C = -Inf;
            case 'pluinf'
                C = +Inf;
            case 'value'
                C = value;
            otherwise
                rethrow(e);
        end %switch
    end %try/catch
end
