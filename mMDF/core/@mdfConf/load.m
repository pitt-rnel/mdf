function load(obj)
    % obj = mdfConf.load(obj)
    %
    % calls the appropriate function to load the configuration data from
    % file
    %
    
    % trying to load file as xml
    try
         obj.loadXml();
         % set type to xml
         obj.fileType = 'xml';
    catch ME
         % no luck with any type
         % set type to unkown
         obj.fileType = 'unknown'
         % pass the Error above
         throw(ME);
    end
end
