function [N V J] = parseJsonNameValue(obj, J)
    % [N V J] = rfConf.parseJsonNameValue(obj, J)
    %
    % extract name and value from json string
    %
    % Input
    %   J = json string
    % Output
    %   N = item name
    %   V = item value
    %
    
    % initialize output
    N = [];
    V = [];
    
    % if json string is empty exit
    if isempty(J)
        return;
    end
    
    % extract item name. 
    % it is a string
    [N J] = obj.parseJsonString(J);
        
    % Skip spaces and the : separator
    while ~isempty(J) && ~isempty(regexp(J(1),'[\s:]','once'))
    	J(1) = [];
    end
    
    % extract item value
	[V J] = obj.parseJsonValue(J);

end
