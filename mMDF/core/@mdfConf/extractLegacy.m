function extractLegacy(obj)
    % mdfConf.extractLegacy(obj)
    %
    % load user configuration from legacy configuration
    %
    
    % get name of function that returns all the user constants
    %
    
    % extract constants function
    % devide file contant in lines
    lines = regexp(obj.fileData,'\r\n|\n','split');
    if ( isempty(lines{end}) )
        lines(end) = [];
    end
    % check number of lines
    if ( length(lines) ~= 2 )
        % userInfo file wrong
        throw(MException('mdfConf:extractLegacy',...
            '1: Invalid userInfo file content'));
    end
    % get user constant functions
    uf = strtrim(lines{2});
    
    % assumes that the constant function is located in the same folder
    % where the userInfo file is located or in subfolder named
    % pathConstants
    % get path from conf file
    dir = fileparts(obj.fileName);
    
    % save current folder
    curr_dir = pwd;
    % switch to user function folder
    cd(dir)
    try
        % get constants from user function
        C = feval(uf);
    catch
        % no user constants function in this folder
        try
            % checking subfolder pathConstants
            cd('pathConstants');
            % try running user constants function
            C = feval(uf);
        catch
            % no user constants function
            throw(MException('mdfConf:extractLegacy',...
                '2: User constants function not found or not able to evaluate it.'));
        end
    end    
    % switch current folder back
    cd(curr_dir);
    
    % add first line of userInfo file under LOCATION\
    % not sure why is needed
    C.LOCATION = strtrim(lines{1});
    
    % build internal configuration structure
    %
    % initialize costant structure C
    obj.confData = struct;
    % add configurations entry
    obj.confData.configurations = struct;
    % add empty configuration items array
    obj.confData.configurations.configuration = {};
    % add empty array for configuration names
    obj.confData.configurations.names = {};
    % add empty array for configuration machine names
    obj.confData.configurations.machines = {};
    
    % insert legacy configuration
    obj.confData.configurations.configuration{end+1} = ...
        struct( ...
            'name', 'Legacy', ...
            'description', ['Legacy configuration from user constants function ' uf], ...
            'constants', C);
    obj.confData.configurations.names{end+1} = 'Legacy';
    obj.confData.configurations.machines{end+1} = 'legacy';
    
end
