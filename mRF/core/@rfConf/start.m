function start(obj)
    % rfConf.start(obj)
    %
    % start selected RNEL db configuration
    %
    
    % first get the configuration
    C = obj.getC;
        
    % reset matlab path setting
    disp(' - Restoring default matlab path.');
    path(pathdef);
    disp('...Done!!!');
    
    % add path for RNEL db functions
    %
    % check if we have the functions info
    if ( ~isfield(C,'FUNCTIONS_ROOT') && ...
            ~exist(C.FUNCTIONS_ROOT,'dir') )
        % we cannot proceed
        throw(MException('rfConf:start',...
                '1: Configuration missing RNEL functions root folder!!!'));
    end
          
    % get list of dirs to ignore
    fdi = {};
    if ( isfield(C,'FUNCTIONS_DIR_IGNORE') && ...
            ~isempty(C.FUNCTIONS_DIR_IGNORE) ) 
        fdi = C.FUNCTIONS_DIR_IGNORE;
    end
        
    % first of all needs to add functions root
    % so we can use the function addpath_recurse
    disp([' - adding functions root path: ' C.FUNCTIONS_ROOT]);
    addpath(C.FUNCTIONS_ROOT);
    disp('...Done!!!');
        
    % add all path needed to use RNEL matlab functions
    disp([' - adding subfolders in functions root path.']);
    % try the new version of addpath_recursive
    % if it does not work, use old one
    try 
        obj.listPaths = addpath_recurse(C.FUNCTIONS_ROOT,fdi);
    catch
        obj.listPaths = {};
        addpath_recurse(C.FUNCTIONS_ROOT,fdi);
    end
    disp('...Done!!!');
    
    % add path for RNEL toolboxes
    
    %
    % check if we have the root folder for the toolboxes
    % and the list of which one we should load
    disp(' - Importing Toolboxes.');
    if ( isfield(C,'TOOLBOX_ROOT') && ...
            exist(C.TOOLBOX_ROOT,'dir') && ...
            isfield(C,'TOOLBOXES_LOAD_ON_START') && ...
            ~isempty(C.TOOLBOXES_LOAD_ON_START) )
        % check if there is a list of dirs to ignore
        tdi = {};
        if ( isfield(C,'TOOLBOX_DIR_IGNORE') )
            tdi = C.TOOLBOX_DIR_IGNORE;
        end
        tPaths = C.TOOLBOXES_LOAD_ON_START;
        for i=1:length(tPaths)
           disp([' -- Importing toolbox: ' tPaths{i}]);
           tPath = fullfile(C.TOOLBOX_ROOT,tPaths{i});
           obj.importToolbox(tPath, tdi);
           disp('...Done!!!');
        end
    else
        disp('...Nothing to do!!!');
    end
    
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
