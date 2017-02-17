function Hs = getHabitats(obj,selection)
    % Hs = mdfConf.getHabtitas(obj,selection)
    %
    % place mark for function getHabs
    % please refer to getHabs help for more info
    %

    s = obj.selection;
    if nargin>1
        s = selection;
    end %if
    Hs = getHabs(obj,s);
end %function

