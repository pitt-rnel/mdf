function Hs = getHabsByType(obj,type,selection)
    % Hs = mdfConf.getHabsByType(obj,type,selection)
    %
    % return habitats of the requested type
    % 
    % output
    %   Hs = (cell of struct) ecosystem habitats
    % input
    %   obj = this object
    %   selection = (string,integer) (optional) selected ecosystem
    %

    s = obj.selection;
    if nargin>2
        s = selection;
    end %if
    Hs = getHabs(obj,s);

    % extract type
    t = cellfun(@(x) x.type, Hs, 'UniformOutput', 0);
    
    % keeps only the habitats of the requested type
    Hs(~strcmp(t,type)) = [];

end %function

