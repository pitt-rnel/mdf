function obj = select(obj,selection)
    % obj = mdfConf.select(obj,selection)
    %
    % select which configuration will be used when starting rnel db
    % If we have only one option in the configuration, the funtion will
    % automatically select that.
    % If selection as argument is not passed, the function will present a
    % menu where the user can pick which option will be used to start the
    % db
    %
    % selection = (string) name of the configuration to be selected
    %             (integer) index of the configuration in the name array

    % try to get the configurations available and to present a menu
    try
        % check if we got a selection in input
        if ( nargin > 1 ) 
            % let's check if we got a string or a 
            switch (class(selection))
                case 'char'
                    % check if it is a valid choice
                    % first check in user names
                    sel = find(cellfun(@(s)any(strcmp(s,selection)), obj.confData.universe.names));
                    if isempty(sel)
                        % tries with machine names
                        sel = find(cellfun(@(s)any(strcmp(s,selection)), obj.confData.universe.machines));
                    end
                    if isempty(sel)
                        % no valid selection
                        selection = '';
                    else
                        % change selection to index
                        selection = sel;
                    end
                case {'single', 'double'}
                    % check if it is a valid choice
                    try
                        % extract machine names from array
                        sel = obj.confData.universe.machines{selection}; 
                    catch
                        % selection provided was wrong
                        selection = '';
                    end
                otherwise
                    selection = '';
            end
        else
            selection = '';
        end
    
        % check if we have a selection
        if isempty(selection)
            % check if we have only one configuration
            % if so, select that one automatically
            if ( length(obj.confData.universe.names) == 1 )
                selection = 1;
            else
                % present the right menu
                switch (obj.menuType)
                    case {'gui', 'auto'}
                        % we need to present a menu and let the user select
                        selection = menu('Please select which configuration you would like to start RNEL db with',obj.confData.configurations.names);
                    otherwise
                        % type: text
                        % build message text
                        message = '\nPlease select which configuration you would like to start RNEL db with:\n';
                        for i = 1:length(obj.confData.universe.names)
                            message =[ message, '\n', int2str(i), ' - ', obj.confData.universe.names{i}];
                        end
                        message = [ message, '\n\n Choice:'];
                        % present text base menu
                        selection = input(message);
                        % check if it is a valid choice
                        try
                            % extract machine names from array
                            sel = obj.confData.universe.machines{selection}; 
                        catch
                            % selection provided was wrong
                            selection = '';
                        end
                end
            end
        end
    
        % set selection
        obj.selection = selection;
    catch
        % configuration has not been loaded or is invalid
        throw(MException('mdfConf:select',...
                '1: Configurations not loaded or invalid!!!'));
    end
end
