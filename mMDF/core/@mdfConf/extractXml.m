function extractXml(obj)
    % mdfConf.extract XML(obj)
    %
    % convert xml xDOM object in fileData to struct and save it in confData
    %
     
    % get xml from file content
    xml = obj.fileData;
    
    % check if we have the "configurations" tag
    confs = xml.getDocumentElement;
    if ~strcmp('configurations',char(confs.getNodeName))
        throw(MException('mdfConf:extractXml:1',...
            'XML structure is missing configurations tag'));
    end
    
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
    
    % initialize auxiliary data structure
    % tokens = values availables for relative_path_to
    obj.temp.tokens = struct;
    % presents = values that needs to be renamed in a different element
    obj.temp.presents = struct;
    
    % get configuration tree
    % we can have multiple
    conf = confs.getElementsByTagName('configuration');
    % check if we have any element
    if conf.getLength == 0
        % no element, no configuration
        % throw error and deals with later
        throw(MException('mdfConf:extractXml:2',...
            'XML structure does not have any configuration tree'));
    end
    % cycle on each configuration element
    for i = 0:(conf.getLength-1)
        % extract single configuration element
        item = conf.item(i);
        % find name of this configuration
        % find all elements tagged/named name.
        items = item.getElementsByTagName('name');
        % initialize user basename
        basename = '';
        % check if we found at least one
        if ( items.getLength > 0 ) 
            % we have at least one
            % get name from first
            basename = strtrim(char(items.item(0).getTextContent));
        end
        % check if we have a valid name
        if ( isempty(basename) )
            basename = 'conf';
        end
        % define machien basename, no spaces and other strange characters
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
        
        % create configuration structure
        % this is the first call, so we pass an empty structure as
        % reference of available values
        obj.confData.configurations.configuration{end+1} = extractXmlHelper(obj,item.getChildNodes);
        % insert configuration name in easy access lists
        obj.confData.configurations.names{end+1} = name;
        obj.confData.configurations.machines{end+1} = mname;
    end
end

