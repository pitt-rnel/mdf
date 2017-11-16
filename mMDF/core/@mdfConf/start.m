function start(obj)
    % mdfConf.start(obj)
    %
    % execute a startup function if indicated in the collections
    % environments
    % global startup function runs first
    %
    
    % first get the environment for the selected ecosystem
    GE = obj.getEnv();
    runStartupFunction('Global',GE);
    
    for i = 1:length(obj.selection)
        E = obj.getEnv(i);
        runStartupFunction(obj.menu.collections(i).human_name,E);
    end %for
end %function
    
function runStartupFunction(name,E)
    % run startup functions
    %
    % check if we have a user defined start up function
    disp([' - Checking if we need to run user-defined start up function for ' name ' environment']);
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
        end %try/catch
    else
        disp('...Nothing to do!!!');
    end %if
    
end %function
