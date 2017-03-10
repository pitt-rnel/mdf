function ohab = getH(obj,habuuid)
    % function ohab = obj.getH(habuuid)
    %
    % provided the habitat uuid, returns the handle to the habitat object
    %
    % input
    % - habuuid (string): habitat uuid
    %
    % output
    % - ohab (connector handle): habitat object handle
    %                            empty otherwise

    ohab = [];
 
    % check input
    if ~ischar(habuuid)
        return;
    end %if

    % build field name
    fn = ['uuid_' habuuid];

    % check if we have the habitat object
    if isfield(obj.habitats.byuuid,fn)
       ohab = obj.habitats.byuuid(fn);
    end %if

end %function

