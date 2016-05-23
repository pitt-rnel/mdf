function [D J] = parseJsonObject(obj,J)
    % [D J] = rfConf.parseJsonObject(obj,J)
    %
    % parse json object
    %
    % Input
    %   J = json string
    % Output
    %   D = object from json element
    %   J = remainder of the json string
    %
    
    % initialize output 
    D = [];
    
    % initialize attribute structure
    attributes = struct;
    
    % initialize single value to false
    single_value = 0;
    
    % iterate on all the sub items of this object
    while ~isempty(J)
        % get first character from json string and remove it from it
        id = J(1);
        J(1) = [];
        
        % takes appropriate action
        switch id
            case '"' 
                % this is the beginning of a string 
                % we have a name/value pair
                [name value remainingJ] = obj.parseJsonNameValue(J);
                % check if property name is empty
                if isempty(name)
                    ME = MException('rfConf:parseJsonObject',['Can not have an empty name: ' json]);
                    ME.throw;
                end
                % check if we have special values
                if name(1)=='-' 
                    % if name starts with '-' this is equivalent to an xml attributes
                    % this item is not a real value but changes the
                    % behavior of the parser

                    % add to attributes
                    % remove '-' from name
                    name(1) = [];
                    attributes.(name) = value;
                    
                elseif strcmp(name,'#text')
                    % if name is #text, this is the real value of parent
                    % item.
                    % we are going to force the parent item to have this
                    % value
                    
                    % force data to be a single value
                    D = value;
                    
                    % set that this is a single value
                    single_value = 1;
                    
                elseif ~single_value
                    % normal case: object
                    % it is used only if a '#text' item does not exists
                    D.(name) = value;
                    % insert in tokens
                    obj.temp.tokens.(name) = value;

                end
                J = strtrim(remainingJ);
                
            case '}' % End of object, so exit the function
                break;
                
            otherwise % Ignore other characters
                J = strtrim(J);
        end
    end
    
    % check if we have attributes and take appropriate action
    fields = fieldnames(attributes);
    if length(fields)
        % check if value is a string/char and perform allowed
        % operations on it
        if isa(D,'char')
        	% check if we have attributes that modify string value
                    
            % relative_to attribute
            % both values need to be strings and path
            % the new value will be the value provided by relative_to
            % prepended to current value
            % also checks if we have a corresponding value to
            % prepend
            if ( isfield(attributes,'relative_path_to') && ...
                    ~isempty(attributes.relative_path_to) && ...
                    isfield(obj.temp.tokens,attributes.relative_path_to) && ...
                    ~isempty(obj.temp.tokens.(attributes.relative_path_to)) && ...
                    isa(obj.temp.tokens.(attributes.relative_path_to),'char') )
            	% concatenate relative path and current value
                D = [obj.temp.tokens.(attributes.relative_path_to) '/' D];
            end
        end
                    
                
        % check if we have attribute 'present_as'
        if ( isfield(attributes,'present_as') && ...
                ~isempty(attributes.present_as) )
            % initialize the 'present' value with the current value
            pvalue = D;
            % check if we have attribute 'present_sub' and if
            % exists a sub item in the struct with that name
            if ( isfield(attributes,'present_sub') && ...
                    ~isempty(attributes.present_sub) && ...
                    isfield(D,attributes.present_sub) ) 
                % this attribute allow to present a substitute the
                % value of the current value with the value of a
                % sub item.
                % Useful when we deal with cell array of strings

                % assign to pvalue the value of the sub item
                pvalue = D.(attributes.present_sub);
            end
            % check if we have attribute 'present_in'
            if ( isfield(attributes,'present_in') && ...
                    ~isempty(attributes.present_in) )
                % we do not want to rename the item here
                % we insert it in temp and pass it along
                obj.temp.presents.(attributes.present_in).(attributes.present_as) = pvalue;
            elseif ( isa(D,'struct') )
                % only if D is already a structure
                % we create another entry with key provided by the
                % attribute 'present_as' and same value
                D.(attributes.present_as) = pvalue;
            end
        end
    end     
                
    % check if we have some 'present_as' to insert under this item
    % the value of this item needs to be a struct
    if ( isfield(obj.temp.presents,name) && ...
            isa(value,'struct') ) 
        % insert values
        fields = fieldnames(obj.temp.presents.(name));
        for ii = 1:length(fields)
        	D.(name).(fields{ii}) = obj.temp.presents.(name).(fields{ii});
        end
        % remove the values
        rmfield(obj.temp.presents,(name));
	end
end
