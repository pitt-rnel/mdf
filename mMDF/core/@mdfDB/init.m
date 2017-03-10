function res = init(obj)
    % function res = obj.init()
    %
    % initialize mdfDb singleton by instantiating 
    % all the habitats with the correct connector
    %

    res = 0;

    % loops on all the habitats specified in the configuration
    for i1 = 1:length(obj.configuration)

        % retrieves the connector type
        connectorString = obj.configuration(i1).connector;
        % instantiate the correct connector for this habitat
        habitatObj = (connectorString)(obj.configuration(i1);
        % build struct key based on uuid
        habuuid = obj.configuration(i1).uuid;
        key = ['uuid_' habuuid];
        % save habitat handle in habitats structure
        obj.habitats.(key) = habitatObj;

    end %for

    res = 1;

end %function init
