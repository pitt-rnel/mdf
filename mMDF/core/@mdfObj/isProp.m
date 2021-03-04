function [res,outtype] = isProp(obj,prop,intype)
    % function [res, outtype] = obj.isProp(prop,intype)
    %
    % return true if prop is a valid property within metadata, data,
    % children or links. False otherwise
    % if a second otput value is required, it will return the type of
    % property too
    %
    % INPUT
    % - prop   : (string) name of the property that we would like to check the
    %            existence for
    % - intype : (string) group where to check for this property
    %
    
    res = false;
    outtypeI = {};
   
    if nargin < 3
        intype = 'all';
    end %if
    % define what needs to be check
    checkMetadata = false;
	checkData = false;
	checkChildren = false;
	checkLinks = false;
    switch (intype)
        case 'metadata'
            checkMetadata = true;
        case 'data'
            checkData = true;
        case 'children'
            checkChildren = true;
        case 'links'
            checkLinks = true;
        otherwise
            checkMetadata = true;
            checkData = true;
            checkChildren = true;
            checkLinks = true;           
    end %switch

    % check in metadata
    if isfield(obj.metadata,prop) && checkMetadata
        res = true;
        outtypeI{end+1} = 'metadata';
    end %if
   
    % check in data
    if any(ismember(prop,obj.mdf_def.mdf_data.mdf_fields)) && checkData
        res = true;
        outtypeI{end+1} = 'data';
    end %if
   
    % check in children
    if any(ismember(prop,obj.mdf_def.mdf_children.mdf_fields)) && checkChildren
        res = true;
        outtypeI{end+1} = 'children';
    end %if
   
    % check in links
    if any(ismember(prop,obj.mdf_def.mdf_links.mdf_fields)) && checkLinks
        res = true;
        outtypeI{end+1} = 'links';
    end %if
   
    if nargout > 1
    	outtype = outtypeI;
    end %if
   
end %function
