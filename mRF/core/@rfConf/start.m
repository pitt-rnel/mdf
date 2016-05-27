function start(obj)
    % rfConf.start(obj)
    %
    % start selected RNEL db configuration
    %
    
    % first get the configuration
    C = obj.getC;
        
    % reset matlab path setting
    %disp(' - Restoring default matlab path.');
    %path(pathdef);
    %disp('...Done!!!');
    
    % add path for RNEL db functions
    %
    % check if we have rf code base
    if ( ~isfield(C,'CODE_BASE') || ...
            ~exist(C.CODE_BASE,'dir') )
        % we cannot proceed
        throw(MException('rfConf:start',...
                '1: Configuration missing RF code folder!!!'));
    end
    % check if we have rf core code base
    if ( ~isfield(C,'CORE_BASE') || ...
            ~exist(C.CORE_BASE,'dir') )
        % we cannot proceed
        throw(MException('rfConf:start',...
                '2: Configuration missing RF core code folder!!!'));
    end
    % check if we have rf data base
    if ( ~isfield(C,'DATA_BASE') || ...
            ~exist(C.DATA_BASE,'dir') )
        % we cannot proceed
        throw(MException('rfConf:start',...
                '3: Configuration missing RF data folder!!!'));
    end
    
    % first of all needs to add functions root
    % so we can use the function addpath_recurse
    disp([' - adding core code path: ' C.CORE_BASE]);
    addpath(C.CORE_BASE);
    disp('...Done!!!');
        
    % run rf init to include all the necessary libraries
    disp([' - running rf init function: rf.init']);
    rf.init();
    disp('...Done!!!');
    
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
