function load(obj)
    % obj = rfConf.load(obj)
    %
    % calls the appropriate function to load the configuration data from
    % file
    %
    
    % trying to load file as xml
    try
         obj.loadXml();
         % set type to xml
         obj.fileType = 'xml';
    catch
        % no luck
        % trying to load fiel as json
        try
            obj.loadJson();
            % set type to json
            obj.fileType = 'json';
        catch
            % no luck yet
            % trying with legacy configuration
            try
                obj.loadLegacy();
                % set type to legacy
                obj.fileType = 'legacy'
            catch ME
                % no luck with any type
                % set type to unkown
                obj.fileType = 'unkown'
                % pass the Error above
                throw(ME);
            end
        end
    end
end
