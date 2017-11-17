function obj = select(obj,selection)
    % obj = mdfConf.select(obj,selection)
    %
    % select which collections should be open when starting rnel db
    % This will be in "or" with the information found in the
    % configuration.
    % if elements are a struct with field selected, it will overwrite the
    % settings
    % If selection as argument is not passed, the function will present a
    % menu where the user can pick which option will be used to start the
    % db
    %
    % selection = cell array of the following:
    %             (string) machine or human name of the collection
    %             (integer) index of the collection
    %             (struct) 
    %                - (string) collection = collection name (human or machine) 
    %                - (boolean) selected = true/false.
    %
    
    % try to get the configurations available and to present a menu
    try
        sel = [];
        % check if we got a selection in input
        if ( nargin > 1 ) 
            % check if we got a cell array or a single value
            switch (class(selection))
                case {'single', 'double', 'struct'}
                    selection = num2cell(selection);
                case {'char'}
                    selection = {selection};
            end %if
            % loop on all the options
            for i = 1:length(selection)
                % let's check if we got a string or a 
                switch (class(selection{i}))
                    case {'logical'}
                        % check if it is a valid choice
                        sel = obj.getCollectionIndex(i);
                        if ~isnan(sel)
                            % change selection to index
                            obj.menu.collections(sel).selected = selection{i};
                        end %if                        
                    case {'single', 'double', 'char'}
                        % check if it is a valid choice
                        sel = obj.getCollectionIndex(selection{i});
                        if ~isnan(sel)
                            % change selection to index
                            obj.menu.collections(sel).selected = true;
                        end %if
                    case {'struct'}
                        % check if we have a selected field
                        sel = obj.getCollectionIndex(selection{i}.collection);
                        if ~isnan(sel)
                            obj.menu.collections(sel).selected = selection{i}.selected;
                        end %if
                end %switch
            end %for
        else
            % user does not have specified an input
            % provides a way for the user to select which collections,
            % he/she wish to start

            % build message text
            message = '\nPlease select which collections you would like to open at RNEL MDF startup:\n';
            for i = 1:length(obj.menu.collections)
            	message =[ message, '\n', int2str(i), ' - ', obj.menu.collections(i).human_name];
            end %for
            message = [ message, '\n\n Enter a comma separated list.\nChoices:'];
            % present text base menu
            selection = input(message,'s');
            % check if it is a valid choice
            try
            	% extract machine names from array
                sel = cellfun(@(item) str2num(item), strsplit(selection,','));
            catch
                % selection provided was wrong
                sel = [];
            end %try/catch

            if ~isempty(sel)
                for i = 1:length(obj.menu.collections)
                    obj.menu.collections(i).selected = any(sel == i);
                end %for
            end %if
        end %if
    
        % set container selection
        obj.setContSel();
    catch
        % configuration has not been loaded or is invalid
        throw(MException('mdfConf:select',...
                '1: An error happened while selecting the collections to be opened at startup'));
    end
end
