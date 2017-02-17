function start(obj)
    % mdfConf.start(obj)
    %
    % start selected MDF ecosystem
    %
    
    % first get the environment for the selected ecosystem
    E = obj.getEnv();
    
    % run startup functions
    %
    % check if we have a user defined start up function
    disp(' - Checking if we need to run user-defined start up function');
    if ( isfield(E,'STARTUP_FUNCTION') && ...
            ~isempty(E.STARTUP_FUNCTION) )
        % try to execute start up function
        try
            if ischar(E.STARTUP_FUNCTION)
                % we got a string defining the function
                funcName = E.STARTUP_FUNCTION;
                % transform it in a function handle
                funcHandle = str2func(funcName);
            elseif isa(E.STARTUP_FUNCTION,'function_handle');
                % we got a function handler
                funcName = func2str(E.STARTUP_FUNCTION);
                funcHandle = E.STARTUP_FUNCTION;
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
