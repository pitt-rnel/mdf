function H = getHab(obj,uuid,selection)
    % Hs = mdfConf.getHab(obj,uuid,selection)
    %
    % return selected habitat for the selected ecosystem
    %
    % output
    %   H = (struct) ecosystem habitat
    % input
    %   obj = this object
    %   uuid = (string) habitat uuid
    %   selection = (string,integer) (optional) selected ecosystem
    %
   
    % get selection
    s = obj.selection;
    if ( nargin > 2 ) 
        s = selection;
    end %if

    % use getEco
    eco = obj.getEco(s);
    
    H = struct();
    % check if we have the constants field
    if ( isa(eco,'struct') && ...
            isfield(eco,'habitats') )
        % find index of the element that we are looking for
        ui = find( ...
            strcmp( ...
                cellfun( ...
                    @(x) x.uuid, ...
                    eco.habitats.habitat, ...
                    'UniformOutput',0), ...
                uuid));
        % check if we found more than one
        if length(ui) > 1
            throw( ...
                MException( ...
                    'mdfConf:getHab', ...
                    ['Habitat error: more than one habitat found with uuid ' uuid]));
        end %if
        if length(ui) == 1
            H = eco.habitats.habitat{ui};
        end %if
    end %if
end %function

