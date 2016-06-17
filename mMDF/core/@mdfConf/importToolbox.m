function importToolbox(obj,toolbox_folder_name,dir_ignore)
    % rneldbConf.importToolbox  Adds a toolbox to the path
    %
    %   importToolbox(obj,toolbox_folder_name,dir_ignore)
    %   
    %   Recursively adds a toolbox directory to the Matlab Path
    %   Originally it was in the functions. 
    %   It had to be moved to rneldbConf class to avoid single version
    %   differences that were causing issues
    %
    %   INPUTS
    %   =======================================================================
    %   toolbox_folder_name: folder name of a toolbox
    %
    %   dir_ignore: (default ''), a cell array of strings of sub_directories not to add
    %
    %   NOTES
    %   =======================================================================
    %   relies on the constant value TOOLBOX_ROOT that has to be present on
    %   the selected configuration
    %
    
    % check if the toolbox folder exists
    if ( exist(toolbox_folder_name,'dir') )
        % it's an absolute path
        toolbox_path = toolbox_folder_name;
    else
        % it's not an absolute path
        % let's try to prepend the toolboxes root folder
        root = obj.confData.configurations.configuration(obj.selection).constants.TOOLBOX_ROOT;
        
        % build full path
        toolbox_path = fullfile(root,toolbox_folder_name);
        % Verify toolbox path
        if ~exist(toolbox_path,'dir')
            error('The specified toolbox path does not exist:\n\t%s',toolbox_path)
        end
    end
    
    % Check for the existence of initialize.m in the toolbox directory.
    init_script = fullfile(toolbox_path,'initialize.m');
    if exist(init_script,'file')
        % push toolbox folder on the stack
        pushd(toolbox_path)
        % Don't just stare at it.
        % Eat it.
        initialize
        % remove toolbox folder
        popd
    else
        % no initialize script, add path recursively
        addpath_recurse(toolbox_path,dir_ignore)
    end
    
    fprintf('Toolbox Loaded: %s\n',toolbox_folder_name)
end

