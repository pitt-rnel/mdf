function [A J] = parseJsonArray(obj,J)
    % [A J] = rfConf.parseJsonArray(obj,J)
    %
    % returns cell array of the json structure
    %
    % input
    %   J = json string
    % output
    %   A = cell array with json elements
    %   J = rest of json string
    %
    
    % initialize output
    A = cell(0,1);
    % loop until json string is empty
    while ~isempty(J)
        % check if the array is closed
        if strcmp(J(1),']') 
            % remove closing square bracket
            J(1) = [];
            % work done
            return
        end
        
        % extract next array element from json string
        [value J] = obj.parseJsonValue(J);
        
        % check if element is empty
        if isempty(value)
            % array element cannot be empty
            ME = MException('rfConf:parseJsonArray',['Parsed an empty value: ' J]);
            ME.throw;
        end
        % insert sub element in array
        A{end+1} = value; %#ok<AGROW>
        
        % remove commas and closing characters if needed
        while ~isempty(J) && ~isempty(regexp(J(1),'[\s,]','once'))
            J(1) = [];
        end
    end
end
