function props = getProps(obj, propType)
    % function child = obj.getChild(propType)
    %
    % return the list of property names for the specified type.
    % if no type is specified, return a structure with all the properties organized by type
    %
    % Input
    % - propType: (string) type of property, we would like the list of. Optional
    %             Accepted values:
    %             - all      : all properties: children, links (Default)
    %             - children : return only the children property names
    %             - links    : return only the links property names 
    %
    % Output
    % - children: (cell array) list of names of the type of property requested
    %             or
    %             (struct) struct with both children and links list of the property names
    %
    
    % initialize output value
    props = [];
    
    % check if propType has been specified
    if nargin < 2
       propType = 'all'
    end
    % makes is all lower case
    propType = lower(propType);

    % check if prop type is accepteble
    switch (propType)
        case('children')
            props = obj.mdf_def.mdf_children.mdf_fields;
            
        case('links')
            props = obj.mdf_def.mdf_links.mdf_fields;

        otherwise
            props = struct( ...
                'children', obj.mdf_def.mdf_children.mdf_fields, ...
                'links', obj.mdf_def.mdf_links.mdf_fields ...
            );
    end %switch
end %function
