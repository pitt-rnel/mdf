function len = getLen(obj,property,type)
    % function length = obj.getLen(property,type)
    %
    % return the length of the property specified.
    % if the same name hasbeen used between children and links, 
    % use type to specify which one has to be referenced
    %
    % Input:
    % - property: (string) name of the property which we on the length of
    % - type: (string) type of the property
    %         allowed values: 
    %         * children
    %         * links
    %
    % Output:
    % - len: (integer) number of items present under the property requested
    %        it will return NaN if the property does not exists, 0 if the
    %        property is empty
    %
    
    % initialize output an dinternal variables
    len = nan;
    pv = nan;

    % check how many input argument we have
    if nargin < 3
        % type is not specified
            
        % we look first in children and than in links
        try 
            pv = {obj.mdf_def.mdf_children.(property).mdf_uuid};
        catch
            try
                pv = {obj.mdf_def.mdf_links.(property).mdf_uuid};
            catch
                return
            end %try/catch
        end %try/catch
    else
        % user specified type of property
        % check type
        switch (type) 
            case {'c', 'children'}
                type = 'mdf_children';
            case {'l', 'links'}
                type = 'mdf_links';
            otherwise
                return
        end %switch
        % get uuids
        try
            pv = {obj.mdf_def.(type).(property).mdf_uuid};
        catch
            return
        end %try/catch
    end %if
    
    if isa(pv,'cell')
        % we found the mdf objects
        len = builtin('length',pv);
    end %if
    
end %function