function H = getHabitat(obj,uuid,selection)
    % H = mdfConf.getHabitats(obj,uuid,selection)
    %
    % place mark for function getHab
    % please refer to getHab help for more info
    %

    s = obj.selection;
    if nargin>2
        s = selection;
    end %if
    H = getHab(obj,s);
end %function
