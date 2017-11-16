function extractXml(obj)
    % mdfConf.extract XML(obj)
    %
    % convert xml xDOM object in fileData to struct and save it in confData
    %
     
    % get xml from file content
    xml = obj.fileData;
    
    % check if we have the "universe" tag as main tag
    confs = xml.getDocumentElement;
    % check if it is a version 1 or 2
    if ~strcmp('configuration',char(confs.getNodeName))
        % no luck with the version
        throw(MException('mdfConf:extractXml',...
            '1: XML structure is missing root universe tag'));
    end
    
    % initialize auxiliary data structure
    % tokens = values availables for relative_path_to
    obj.temp.tokens = struct;
    % presents = values that needs to be renamed in a different element
    obj.temp.presents = struct;
    
    % initialize costant structure C
    obj.confData = obj.extractXmlHelper(confs);
    
    % check if we have correct configuration for collections
    if ~isfield(obj.confData,'collections') && ...
            ~isfield(obj.confData.collections,'collection') && ...
            length(obj.confData.collections.collection) == 0
        % no element, no configuration
        % throw error and deals with later
        throw(MException('mdfConf:extractXml',...
            '2: XML conf structure does not have the correct configuration for collections'));
    end
	% check if we have correct configuration for containers
    if ~isfield(obj.confData,'containers') && ...
            ~isfield(obj.confData.containers,'container') && ...
            length(obj.confData.containers.container) == 0
        % no element, no configuration
        % throw error and deals with later
        throw(MException('mdfConf:extractXml',...
            '3: XML conf structure does not have the correct configuration for containers'));
    end
    % check if we have version
    if ~isfield(obj.confData,'version')
        % no element, no configuration
        % throw error and deals with later
        throw(MException('mdfConf:extractXml',...
            '4: XML conf structure does not have version specified'));
    end
    
    % check if there is any class fixing to be done
    if ~isa(obj.confData.collections.collection,'cell')
        if length(obj.confData.collections.collection) > 1
            obj.confData.collections.collection = num2cell(obj.confData.collections.collection);
        else
            obj.confData.collections.collection = {obj.confData.collections.collection};
        end %if
    end %if
    if ~isa(obj.confData.containers.container,'cell')
        obj.confData.containers.container = {obj.confData.containers.container};
    end %if

%     % cycle on each configuration element
%     for i = 0:(collections.getLength-1)
%         % extract single configuration element
%         collection = collections.item(i);
%         % find name of this configuration
%         % find all elements tagged/named name.
%         items = collection.getElementsByTagName('name');
%         % initialize user basename
%         basename = '';
%         % check if we found at least one
%         if ( items.getLength > 0 ) 
%             % we have at least one
%             % get name from first
%             basename = strtrim(char(items.item(0).getTextContent));
%         end
%         % check if we have a valid name
%         if ( isempty(basename) )
%             basename = 'conf';
%         end
%         % define machine basename, no spaces and other strange characters
%         % find all elements tagged/named name.
%         items = collection.getElementsByTagName('name');
%         mbasename = '';
%         % check if we found at least one
%         if ( items.getLength > 0 ) 
%             % we have at least one
%             % get name from first
%             mbasename = strtrim(char(items.item(0).getTextContent));
%         end
%         % check if we have a valid name
%         if ( isempty(mbasename) )
%             mbasename = 'conf';
%         end        
%         mbasename = regexprep(mbasename,'[ ?~]','_');
%         % find out if we have duplicates
%         % appends an index at the end
%         name = basename;
%         mname = mbasename;
%         counter = 1;
%         % check that we do not have another configuration with the same name
%         while ~isempty(find(ismember(obj.confData.configuration.machines,mname)))
%             % append counter to machine name and user name
%             mname = [mbasename '-' int2str(counter)];
%             name = [basename ' (' int2str(counter) ')'];
%             counter = counter +1
%         end
%         
%         % create configuration structure
%         % this is the first call, so we pass an empty structure as
%         % reference of available values
%         obj.confData.configuration.collections{end+1} = extractXmlHelper(obj,collection.getChildNodes);
%         % insert configuration name in easy access lists
%         obj.confData.configuration.names{end+1} = name;
%         obj.confData.configuration.machines{end+1} = mname;
%     end
end

