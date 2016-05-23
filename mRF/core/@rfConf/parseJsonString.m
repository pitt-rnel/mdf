function [S J] = parseJsonString(obj, J)
    % [S J] = rfConf.parseJsonString(obj, J)
    %
    % extract next string from json string
    %
    % input
    %   J = json string
    % output
    %   S = string extracted
    %   J = remainder of json string 
    %
    
    % initialize output
    S = [];
    
    % iterate on json string until is empty
    while ~isempty(J)
        % extract first letter and remove it from json string
        letter = J(1);
        J(1) = [];
        
        % select appropriate action
        switch lower(letter)
            case '\' 
                % Deal with escaped characters
                % check if json is string contains something else
                if ~isempty(J)
                    % extract escaped code and remove it from json string
                    code = J(1);
                    J(1) = [];
                    % prepare next char
                    switch lower(code)
                        case '"'
                            % double quotes
                            new_char = '"';
                        case '\'
                            % back slash
                            new_char = '\';
                        case '/'
                            % forward slash
                            new_char = '/';
                        case {'b' 'f' 'n' 'r' 't'}
                            % tabs and so on
                            new_char = sprintf('\%c',code);
                        case 'u'
                            % unice characters
                            if length(json) >= 4
                                new_char = sprintf('\\u%s',json(1:4));
                                json(1:4) = [];
                            end
                        otherwise
                            % other cases that are not contemplated
                            new_char = [];
                    end
                end
                
            case '"' 
                % we got double quote
                % Done with the string
                break
                
            otherwise
                % everything else is a normal character
                new_char = letter;
        end
        % Append the new character
        S = [S new_char]; %#ok<AGROW>
    end
end
