function res = removeMetadataProperty(obj,field)
    % function res = obj.removeMetadataProperty(field)
    % 
    % remove metadata property from object's metadata
    % it will remove only the first level field.
    % it does not work on nested fields
    
    res = false;
    
    if isa(field,'char')
        field = strsplit(field,'.');
    end %if
    
    obj.metadata = removeRecursive(obj.metadata,field);
    
    res = true;
    
end %function

function outputMd = removeRecursive(inputMd,field)
    outputMd = inputMd;
    switch class(field)
        case 'cell'
            topfield = field{1};
            if length(field) == 1
                outputMd = rmfield(inputMd,topfield);
            else
                outputMd.(topfield) = removeRecursive(inputMd.(topfield),{field{2:end}});
            end %if
        case 'char'
            outputMd = rmfield(inputMd,topfield);
        otherwise
            throw( ...
                MException( ...
                    'MDF:removeMetadataProperty', ...
                    'Wrong field type'));
    end %switch
end  %function