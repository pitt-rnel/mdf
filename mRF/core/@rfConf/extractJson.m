function extractJson(obj)
    % rfConf.extractJson(obj)
    %
    % convert json string in fileData to struct and save it in confData
    %
        
    json = obj.fileData;
    
    % check if we have a json string with the correct begin
    if ( ~strncmp(regexprep(obj.fileData,'[\n ]',''),'{"configurations":{"configuration":',35) )
        throw(MException('rfConf:extractJson:1',...
                'JSON data structure incorrect!!!'));
    end
    
    % initialize configuration data to empty cell array
    obj.confData = struct;
    
    % initialize auxiliary data structure
    % tokens = values availables for relative_path_to
    obj.temp.tokens = struct;
    % presents = values that needs to be renamed in a different element
    obj.temp.presents = struct;
    
    % parse json string and create structure
    [D J] = obj.parseJsonValue(json);
    % check if we got only one element
    % if more, there is an error in the conf file
    if ( length(D) ~= 1 )
        throw(MException('rfConf:extractJson:2',...
                'JSON data structure incorrect!!!'));
    end
    % transfer data to confData
    % if D is a struct, extract only the first one
    if ( isa(D,'cell') )
        obj.confData = D{1};
    else
        obj.confData = D;
    end
    % check if we have the right structure
    if ( ~isfield(obj.confData,'configurations') )
        throw(MException('rfConf:extractJson:3',...
                'JSON data structure incorrect!!! No configurations.'));
    end
    if ( ~isfield(obj.confData.configurations,'configuration') )
        throw(MException('rfConf:extractJson:4',...
                'JSON data structure incorrect!!! No configuration.'));
    end
    
    % initialize user names and machine names
	obj.confData.configurations.names = {};
	obj.confData.configurations.machines = {};
    
    % cycle on each configuration element to extract names
    for i = 1:length(obj.confData.configurations.configuration)
        % extract single configuration element
        item = obj.confData.configurations.configuration{i};
        % initialize user basename
        basename = '';
        % check if we found at least one
        if ( isfield(item,'name') ) 
            % we have at least one
            % get name from first
            basename = item.name;
        end
        % check if we have a valid name
        if ( isempty(basename) )
            basename = 'conf';
        end
        % define machine basename, no spaces and other strange characters
        mbasename = regexprep(basename,'[ ?~]','_');
        % find out if we have duplicates
        % appends an index at the end
        name = basename;
        mname = mbasename;
        counter = 1;
        % check that we do not have another configuration with the same name
        while ~isempty(find(ismember(obj.confData.configurations.machines,mname)))
            % append counter to machine name and user name
            mname = [mbasename '-' int2str(counter)];
            name = [basename ' (' int2str(counter) ')'];
            counter = counter +1
        end
        % insert configuration name in easy access lists
        obj.confData.configurations.names{end+1} = name;
        obj.confData.configurations.machines{end+1} = mname;
    end
end

