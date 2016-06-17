function [N J] = parseJsonNumber(obj, J)
    % [N J] = mdfConf.parseJsonNumber(obj, J)
    %
    % extract number from json string
    %
    % input
    %   J = json string
    % output
    %   N = number extracted
    %   J = remainder of json string
    %
    
    % initialize output
    N = [];
    % if json strin gis empty exits
	if isempty(json)
        return
    end
    
    % Validate the floating point number using a regular expression
    [s e] = regexp(J,'^[\w]?[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?[\w]?','once');
    % check if we found anything
    if ~isempty(s)
        % extract number characters from json string and remove them
        num_str = J(s:e);
        J(s:e) = [];
        % get numeric value
        N = str2double(strtrim(num_str));
    end
end
