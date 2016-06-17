function loadXml(obj)
    % rneldbConf.loadXml(obj)
    %
    % load xml configuration dat afrom file
    %
    
    % load xml file
    obj.fileData = xmlread(obj.fileName);
    
end

