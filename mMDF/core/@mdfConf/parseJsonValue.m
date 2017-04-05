function [D J] = parseJsonValue(obj,J)
    % [D J] = mdfConf.parseJsonValue(obj,json)
    %
    % parse next element from json string
    %
    % input
    %   J = (string) json to be parsed
    % output
    %   D = data structure parsed from the json string
    %   J = json string left to be parsed
    %
    
    % initialized output data structure
    D = [];
    % if empty do nothing
    if isempty(J)
        return
    end
       
    % extract first character and remove it from jsdon string
    id = J(1);
    J(1) = [];
        
    % remove heading and trailing spaces from json string
    J = strtrim(J);
        
    % based on the first character, we take appropriate action
    switch lower(id)
        case '"'
            % we need to parse a string
            % in json, strings are included in double quotes
            [D J] = obj.parseJsonString(J);
                
        case '{'
            % the next element is an object
            [D J] = obj.parseJsonObject(J);
                
        case '['
            % next element is an array
            [D J] = obj.parseJsonArray(J);
                
        case 't'
            % boolean element true
            value = true;
            if (length(J) >= 3)
                J(1:3) = [];
            else
                ME = MException('mdfConf:parseJsonValue',['Invalid TRUE identifier: ' id J]);
                ME.throw;
            end
                
        case 'f'
            % boolean element false
            value = false;
            if (length(J) >= 4)
            	J(1:4) = [];
            else
            	ME = MException('mdfConf:parseJsonValue',['Invalid FALSE identifier: ' id J]);
            	ME.throw;
            end
                
        case 'n'
            % null element
            value = [];
            if (length(J) >= 3)
                J(1:3) = [];
            else
            	ME = MException('mdfConf:parseJsonValue',['Invalid NULL identifier: ' id J]);
            	ME.throw;
            end
                
        otherwise
            % everything else is a number
        	[D J] = obj.parseJsonNumber([id J]); % Need to put the id back on the string
    end
end
