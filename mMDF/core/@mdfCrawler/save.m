function res = save(obj,basefile)
    %
    % function res = mdfCrawler.save(filebase)
    %
    % after rcrawler or hcrawler have been run successfully, this function
    % save the data in json format to be used in visualization or further
    % analysis
    % output are 2 files:
    % 1) <basefile>.rel.json : list of the relationships between objects
    % 2) <basefile>.obj.json : list of the objects found during the crawl
    %
    
    res = 0;
    
    % prepare file names
    relfilename = [basefile '.rel.json'];
    objfilename = [basefile '.obj.json'];
    
    % check if files exist already
    if exist(relfilename,'file')
        throw(MException('mdfCrawler::save', ['Relations file ' relfilename ' already exists']));
    elseif exist(objfilename,'file')
        throw(MException('mdfCrawler::save', ['Objects file ' relfilename ' already exists']));
    end %if
    
    % save relations file
    savejson('',obj.relList,relfilename);
    % save objects file
    savejson('',obj.objList,objfilename);
    
    res = 1;
end %function