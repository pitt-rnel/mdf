function U = getUniv(obj)
    % U = mdfConf.getUniv(obj)
    %
    % returns the complete configuration structure, called universe
    %
    % output
    %   U = (struct) complete configuration tree extracted from
    %               configuration file, aka universe
    %
    
    U = obj.confData.universe.ecosystem{:};
    
end
