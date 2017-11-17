function outdata   = getSelection(obj)
    % outdata = mdfConf.getSelection(obj)
    %
    % return which collections are set to be open at startup
    %
    % output
    %   uuid = selected configuration uuid
    %   human_name = selected configuration human name
    %   machine_name = selected configuration machine name
    %   index = selected configuration index in names array
    %
    
    % we assume that the configuration is loaded
    %
    % initialize output
    outdata = struct( ...
        'uuid', [], ...
        'human_name', [], ...
        'machine_name', [], ...
        'index', [] ...
    );
    outdata(end) = [];
       
    % loop on all the collections and return the ones that are selected
    for i = 1:length(obj.menu.collections)
        if obj.menu.collections(i).selected
            outdata(end+1) = struct( ...
                'uuid', obj.menu.collections(i).uuid, ...
                'human_name', obj.menu.collections(i).human_name, ...
                'machine_name',obj.menu.collections(i).machine_name, ...
                'index', i ...
            );
        end %if
    end %for
end %function

