function res = getHabitats(obj,habuuid)
    % function res = obj.getHabitats(habuuid)
    %
    % return all or the selected habitat object handles
    %
    % Input
    % - habuuid (string): habitat uuid (optional)
    %
    % Output
    % - res (array of object handles): handles to the habitats
    %

    res = [];

    if nargin>1
        % user wants specific habitat
        res = obj.getH(habuuid);
    else
        % user wants all the habitats
        res = cellfun(@(k) obj.habitats.byuuid.(k),obj.habitats.uuids,'UniformOutput',0);
    end %if

end %function 
