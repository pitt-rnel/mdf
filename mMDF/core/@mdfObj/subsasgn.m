function varargout = subsasgn(obj,S,V)

    if strcmp(S(1).type,'.')
        % check if user is asking for a valid object property
        if length(intersect(S(1).subs,properties(obj))) || ...
            length(intersect(S(1).subs,methods(obj)))
            % nothing to do, pass it along
            
            % check if user wants a data property
        elseif length(intersect(S(1).subs,fields(obj.data)))
            % obj.<data-prop>
            % becomes
            % obj.data.<data-prop>
            S = [ ...
                struct{ ...
                    'type', '.', ...
                    'subs', 'data' },
                S];
        elseif length(intersect(S(1).subs,fields(obj.metadata)))
            % obj.<metadata-prop>
            % becomes
            % obj.metadata.<metadata-prop>
            S = [ ...
                struct{ ...
                    'type', '.', ...
                    'subs', 'metadata' },
                S];
        elseif length(intersect(S(1).subs,obj.mdf_def.mdf_children.mdf_fields))
            % obj.<child-prop>
            % becomes
            % obj.children.<child-prop>
            S = [ ...
                struct{ ...
                    'type', '.', ...
                    'subs', 'children' },
                S];
        elseif length(intersect(S(1).subs,{'d'}))
            % obj.d.<data-prop>
            % becomes
            % obj.data.<data-prop>
            S(1).subs = 'data';
        elseif length(intersect(S(1).subs,{'md'}))
            % obj.md.<metadata-prop>
            % becomes
            % obj.metadata.<metadata-prop>
            S(1).subs = 'metadata';
        elseif length(intersect(S(1).subs,{'c', 'child'}))
            % obj.c.<child-prop>, obj.child.<child-prop>
            % becomes
            % obj.children.<child-prop>
            S(1).subs = 'children';
        end %if
    end %if
    
    % check if assignment is allowed
    if strcmp(S(1).type,'.')
        if strcmp(S(1).subs,'data') && ( ...
                length(S) == 1 || ...
                ~strcmp(S(2).type,'.') )
            throw(MException('mdfObj:subsasgn','Invalid data property assignment'));
        end %if
    end %if
    
    % check if we need to return a child or a parent or an object property
    
    varargout = {builtin('subsasgn',obj,S,V)};

    % updates internal data structure
    if strcmp(S(1).type,'.')
        if strcmp(S(1).subs,'data') && strcmp(S(2).type,'.')
            % update internal data structures
            % get field name
            field = S(2).subs;
            % check if field is already in list
            j = find(strcmp(obj.mdf_def.mdf_data.mdf_fields,field));
            if isempty(j)
                % new field, append at the end
                obj.mdf_def.mdf_data.mdf_fields{end+1} = field;
                j = length(obj.mdf_def.mdf_data.mdf_fields);
            end %if
            % update data property info
            obj.setDataInfo(field);
            % set that this dat aproperty is loaded and has changed
            obj.status.changed.data.(field) = 1;
            obj.status.loaded.data.(field) = 1;
        elseif strcmp(S(1).subs,'metadata')
            % update the changed status
            obj.status.changed.metadata = 1;
        end %if
    end %if
end %function
