function ohabs = getHsbT(obj,habtype)
    % function ohabs = obj.getHsbT(habtype)
    %
    % provided the habitat type, returns the handle to the all the habitat objects of that type
    %
    % input
    % - habtype (string): habitat type
    %
    % output
    % - ohabs (connector handle): habitat object handle
    %                            empty otherwise

    ohabs = [];
 
    % check input
    if ~ischar(habtype)
        return;
    end %if

    % build field name
    fn = ['t_' habuuid];

    % check if we have the habitat object
    if isfield(obj.habitats.bytype,fn)
       ohabs = obj.habitats.bytype.(fn);
    end %if

end %function

