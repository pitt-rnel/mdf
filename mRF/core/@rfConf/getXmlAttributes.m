function A = getXmlAttributes(obj,item)
    % rfConf.getAttributes(obj,item)
    %
    % extract attributes from xml item
    %
    % item = xml tag
    %
    % A = structure with attributes and values
    %     keys = attribute names
    %     values = attribute values
    %
    
    % initialize attribute struct
    A = struct;
    % check if we have attributes
    if ( ~item.hasAttributes ) 
        return
    end
    % get attributes from item
    attributes = item.getAttributes;
    % check if we have attributes
    if attributes.getLength == 0
        % no attributes
        return
    end
    % yes we do have attributes
    attributes = item.getAttributes;
    % transfer them in the structure
    for i = 0:(attributes.getLength-1)
    	% get name
        name = strtrim(char(attributes.item(i).getName));
        % get value
        value = strtrim(char(attributes.item(i).getValue));
        % insert in outpuit structure
        A.(name) = value;
    end
end
