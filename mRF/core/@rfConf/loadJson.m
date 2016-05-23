function loadJson(obj)
    % rfConf.loadJson(obj)
    %
    % extract configuration data from json data loaded from conf file
    %
    
    % loads json as one string 
    % extract will take care of interpret it correctly
    fid = fopen(obj.fileName);
    obj.fileData = fscanf(fid,'%c');
    fclose(fid);
    
    % check that the data loaded from the json file starts with the correct
    % pattern
    if ( ~strncmp(regexprep(obj.fileData,'[\n ]',''),'{"configurations":{"configuration":',35) )
        throw(MException('rfConf:loadJson',...
                '1: JSON data structure incorrect!!!'));
    end

end
