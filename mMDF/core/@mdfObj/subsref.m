function [res] = subsref(obj,S)
    %
    % function [res] = obj.subsref(s).
    %
    % overload default subsref matlab function

    % check if the object itself is a single object or a vector
    if ~isvector(obj) && ( max(builtin('size',obj)) > 1 )
        % we got a matrix, and we do not know what to do with it
        throw(MException( ...
            'mdfObj:subsref', ...
            ['Operation not possible. Please transform object in a vector']));
    elseif strcmp(S(1).type,'()')
        % check if the first operation is an array indexing
        % we assume that the user knows the length of the vector
        %
        % if that's the case, we extract the element and apply the rest of the
        % subsref steps
        if length(S(1).subs) ~= 1
            % check if we got multiple dimensions in the slicing
            throw(MException( ...
                'mdfObj:subsref', ...
                ['Please specify only one index. This object can only be a vector']));
        elseif length(S(1).subs{1}) == 1
            % the user specify only one index
            % the user wants to extract a specific element from the array
            res = obj(S(1).subs{1});
            % remove requested operation from S
            S(1) = [];
            % if we have more subsref steps, go ahead and perform them
            if length(S) > 0
                res = res.subsref(S);
            end %if
            % we are done
            return
        else
            % the user has specified multiple indexes to be extracted
            % applies the remaining subsref to the selected elements and
            % returns a cell array
            %
            %
            % get the selected indexes
            selectedIndexes = S(1).subs{1};
            % remove indezing from subsref operation
            S(1) = [];
            % loops on the indexes and applies the subsrefs operations
            res = arrayfun(@(item)(item.subsref(S)),obj(selectedIndexes),'UniformOutput',0);
            % we are done
            return;
        end % if
    elseif length(obj)>1
        % now checks if we have n array in input and if we should perform the
        % subsref operation on all the elements
        %
        % we assume that we should apply the operation requested to
        % every single object in the array
        % prepare output
        res = {};
        % loops on all the elements
        res = arrayfun(@(item)(item.subsref(S)),obj,'UniformOutput',0);
        % we are done
        return
    end %if

    % manage the different cases
    %
	% obj(<string>)
    % becomes obj.<string>
    if length(S)==1 && ...
            strcmp(S.type,'()') && ...
            isa(S.subs,'cell') && ...
            length(S.subs) == 1 && ...
            ischar(S.subs{1})
        S.type = '.';
        S.subs = S.subs{1};    
    end %if
    
    % obj.[...]
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
                struct( ...
                    'type', '.', ...
                    'subs', 'data' ), ...
                S];
        elseif length(intersect(S(1).subs,fields(obj.metadata)))
            % obj.<metadata-prop>
            % becomes
            % obj.metadata.<metadata-prop>
            S = [ ...
                struct( ...
                    'type', '.', ...
                    'subs', 'metadata' ), ...
                S];
        elseif length(intersect(S(1).subs,fields(obj.mdf_def.mdf_children)))
            % obj.<child-prop>
            % becomes
            % obj.children.<child-prop>
            S = [ ...
                struct( ...
                    'type', '.', ...
                    'subs', 'children' ) ...
                S];
        elseif isfield(obj.mdf_def,'mdf_links') && length(intersect(S(1).subs,fields(obj.mdf_def.mdf_links)))
            % obj.<link-prop>
            % becomes
            % obj.links.<child-prop>
            S = [ ...
                struct( ...
                    'type', '.', ...
                    'subs', 'links' ) ...
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
        elseif length(intersect(S(1).subs,{'l', 'link'}))
            % obj.l.<link-prop>, obj.link.<link-prop>
            % becomes
            % obj.links.<child-prop>
            S(1).subs = 'links';
        end %if

        % obj.data(<string>)
        % obj.metadata(<string>)
        % obj.children(<string>)
        if length(S)>1 && strcmp(S(2).type,'()')
            % check if we are calling a methods
            if length(intersect(S(1).subs,methods(obj)))
                % we are calling a valid methods
                % nothing to do
            elseif length(intersect(S(1).subs,{'data','metadata','children','links'}))
                % we are requesting a data value
                S(2).type = '.';
            end %if
        end %if
    end %if
    
    % now decide how to treat the different properties
    if strcmp(S(1).subs, 'children')
        % retrieve all the uuids for the object requested
        if length(S) == 1
            % user wants all the childrens
            % obj.children
            %
            % initialize output
            res = struct();
            % loop on all childrens
            cl = obj.mdf_def.mdf_children.mdf_fields;
            for i = 1:length(cl)
                cp = cl{i};
                % initialize oputput field
                res.(cp) = [];
                % load all the children of the same type
                for j = 1:length(obj.mdf_def.mdf_children.(cp))
                    % load object and insert in output
                    res.(cp) = [ ...
                        res.(cp) ...
                        mdfObj.load( ...
                            struct( ...
                                'uuid', ...
                                obj.mdf_def.mdf_children.(cp)(j).mdf_uuid))];
                end %for
            end %for
        elseif strcmp(S(2).type,'.') && ( ...
                length(S) == 2 || ...
                ( length(S) > 2 && strcmp(S(3).type,'.') ) )
            % user wants all children of one kind
            % obj.children.<child>[.<prop>]
            %
            % try to get the right child
            try
                cidl = {obj.mdf_def.mdf_children.(S(2).subs).mdf_uuid};
                if isa(cidl,'char')
                    cidl = {cidl};
                end %if
            catch
                throw(MException('mdfObj:subsref',['Child property "' S(2).subs '" not found']));
            end %try/catch
            % load all the objects
            res = [];
            for i = 1:length(cidl)
                res = [res mdfObj.load(struct('uuid',cidl{i}))];
            end %for
            % check if user requested sub properties
            if length(S) > 2
                res = feval('subsref',res,S(3:end));
            end %if
        elseif length(S) >= 3 && strcmp(S(3).type,'()')
            % user wants a specific child of specific type
            % obj.children.<child>[<i>][.<prop>]
            %
            % try to get the right child
            try
                % issues with the type of children
                % needs to be addresses, but in the mean time,
                % let's check which type of variable we have
                switch class(obj.mdf_def.mdf_children.(S(2).subs))
                    case 'cell'
                        uuid = obj.mdf_def.mdf_children.(S(2).subs){S(3).subs{1}}.mdf_uuid;
                    case 'struct'
                        uuid = obj.mdf_def.mdf_children.(S(2).subs)(S(3).subs{1}).mdf_uuid;
                    otherwise
                        throw(MException('mdfObj:subsref',['Child property "' S(2).subs '(' num2str(S(3).subs{1}) ')" correupted']));
                end %switch
            catch
                throw(MException('mdfObj:subsref',['Child property "' S(2).subs '(' num2str(S(3).subs{1}) ')" not found']));
            end %try/catch
            % load children
            res = mdfObj.load(uuid);
            % check if we need to go deeper or not
            if length(S) > 3
                % yes we do
                % we have a case like:
                % obj.children.<child>(<i>).<child-prop>
                res = feval('subsref',res,S(4:end));
            end %if
            
        end %if
        return;
        
    elseif strcmp(S(1).subs, 'links')
        % retrieve all the uuids for the link property requested
        if length(S) == 1
            % user wants all the links
            % obj.links
            %
            % initialize output
            res = struct();
            % loop on all links
            ll = obj.mdf_def.mdf_links.mdf_fields;
            for i = 1:length(ll)
                lp = ll{i};
                % initialize output field
                res.(lp) = [];
                % load all the links of the same type
                for j = 1:length(obj.mdf_def.mdf_links.(lp))
                    % load object and insert in output
                    res.(lp) = [ ...
                        res.(lp) ...
                        mdfObj.load( ...
                            struct( ...
                                'uuid', ...
                                obj.mdf_def.mdf_links.(lp)(i).mdf_uuid))];
                end %for
            end %for
        elseif strcmp(S(2).type,'.') && ( ...
                length(S) == 2 || ...
                ( length(S) > 2 && strcmp(S(3).type,'.') ) )
            % user wants all links of one kind
            % obj.links.<link>[.<prop>]
            %
            % try to get the right link property
            try
                lidl = obj.mdf_def.mdf_links.(S(2).subs).mdf_uuid;
                if isa(lidl,'char')
                    lidl = {lidl};
                end %if
            catch
                throw(MException('mdfObj:subsref',['Link property "' S(2).subs '" not found']));
            end %try/catch
            % load all the objects
            res = [];
            for i = 1:length(lidl)
                res = [res mdfObj.load(struct('uuid',lidl{i}))];
            end %for
            % check if user requested sub properties
            if length(S) > 2
                res = feval('subsref',res,S(3:end));
            end %if
        elseif length(S) >= 3 && strcmp(S(3).type,'()')
            % user wants a specific link of specific type
            % obj.links.<link>[<i>][.<prop>]
            %
            % try to get the right link
            try
                uuid = obj.mdf_def.mdf_links.(S(2).subs)(S(3).subs{1}).mdf_uuid;
            catch
                throw(MException('mdfObj:subsref',['Links property "' S(2).subs '[' S(3).subs{1} ']" not found']));
            end %try/catch
            % load children
            res = mdfObj.load(uuid);
            % check if we need to go deeper or not
            if length(S) > 3
                % yes we do
                % we have a case like:
                % obj.children.<child>(<i>).<child-prop>
                res = feval('subsref',res,S(4:end));
            end %if
            
        end %if
        return;
        
    elseif strcmp(S(1).subs,'data')
        % check which data we need to load
        if length(S)>1
            % user has specified which data we need to return
            % obj.data.<prop>
            % load data if necessary
            obj.dataLoad(S(2).subs);
        else
            % user wants all the data
            % obj.data
            dl = obj.mdf_def.mdf_data.mdf_fields;
            % load all the data properties in list
            for i = 1:length(dl)
                % load property if necessary
                obj.dataLoad(dl{i});
            end %for
        end %if
    end %if
    % try to capture output
    try 
        res = builtin('subsref',obj,S);
    catch
        % try to call without output
        try 
            builtin('subsref',obj,S);
        catch e
            e.rethrow();
        end %try/catch
    end %try/catch
end %function
