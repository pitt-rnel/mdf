function start(obj)
    % mdfConf.start(obj)
    %
    % start selected RNEL db configuration
    %
    
    % first get the configuration
    C = obj.getC;
    
    % run startup functions
    %
    % check if we have a user defined start up function
    disp(' - Checking if we need to run user-defined start up function');
    if ( isfield(C,'STARTUP_FUNCTION') && ...
            ~isempty(C.STARTUP_FUNCTION) )
        % try to execute start up function
        try
            if ischar(C.STARTUP_FUNCTION)
                % we got a string defining the function
                funcName = C.STARTUP_FUNCTION;
                % transform it in a function handle
                funcHandle = str2func(funcName);
            elseif isa(C.STARTUP_FUNCTION,'function_handle');
                % we got a function handler
                funcName = func2str(C.STARTUP_FUNCTION);
                funcHandle = C.STARTUP_FUNCTION;
            end
            % run startup function
            funcHandle(obj);
        catch ME
            disp(['...Error: startup function: ' funcName ' threw an error.']);
            simpleExceptionDisplay(ME)
        end
    else
        disp('...Nothing to do!!!');
    end
    
    
end
