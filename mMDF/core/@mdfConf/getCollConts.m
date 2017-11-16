function Cs = getCollConts(obj,collid)
    % Cs = mdfConf.getCollConts(obj)
    %
    % return all the containers configured within this collection
    %
    % output
    %   Cs = (array of strut) containers
    % input
    %   obj = this object
    %
    
    sel = obj.getCollectionIndex(collid); 
    Cs = obj.confData.collections.collection{sel}.containers.container;

end %function

