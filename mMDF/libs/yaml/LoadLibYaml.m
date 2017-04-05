function LoadLibYaml()
    % import java library
    
    % path to the current script
    [path,~,~] = fileparts(mfilename('fullpath'));
    % find full path of this yaml library
    yamlPath = fullfile(path,'external','snakeyaml-1.9.jar');
    % check if it is already in path
    if not(ismember(yamlPath, javaclasspath ('-dynamic')))
        % add path to java library
        javaaddpath(yamlPath); % javaaddpath clears global variables...!?
        % import java library
        import('org.yaml.snakeyaml.*');
    end %if
    
end %function