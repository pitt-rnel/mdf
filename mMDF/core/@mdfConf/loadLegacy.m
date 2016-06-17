function loadLegacy(obj)
    % mdfConf.loadLegacy(obj)
    %
    % load legacy configuration file
    %
    
    % load legacy configuration
    fid = fopen(obj.fileName);
    obj.fileData = fscanf(fid,'%c');
    fclose(fid);

end
