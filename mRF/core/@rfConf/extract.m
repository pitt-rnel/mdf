function obj = extract(obj)
    % obj = rfConf.extract(obj)
    %
    % extract configuration from data extracted from configuration file
    %

    % checks if fileData has data 
    if ( isempty(obj.fileData) )
         throw(MException('rfConf:extract:1',...
            'No file data available. Please specify configuration file to load!!'));
    end
       
    switch (obj.fileType)
        case 'xml'
            extractXml(obj);
        case 'json'
            extractJson(obj);
        case 'legacy'
            extractLegacy(obj);
        otherwise
            % nothing to do
            % initialize configuration data
            obj.confData = struct;
    end
end
