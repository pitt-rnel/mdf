function C = getConstant(obj,constant, error, value)
    % C = obj.getConstant(obj,constant, error, value)
    %
    % return the selected constant in the current configuration
    %
    % output
    %   C = (variable) value of the constant requested
    % input
    %   obj = this object
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
    
    % check 
    if nargin < 3
        error = 'exception';
    end %if
    if nargin < 4
        default = 'NO-DEFAULT-VALUE';
    end %if
    
    try 
        % get current configuration
        cC = obj.getConf();
        % get constant
        C = eval(['cC.constants.' constant]);
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
