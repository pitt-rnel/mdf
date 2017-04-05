%--------------------------------------------------------------------------
% Accept a yaml java object and parses it and return a matlab data struct.
% 
% input
%  - (string) r : yaml as java object returned by yaml.load function
%
% output
%  - (struct) result : yaml as matlab object
%
function result = scan_yaml(r)
    if isa(r, 'char')
        result = scan_string(r);
    elseif isa(r, 'double')
        result = scan_numeric(r);
    elseif isa(r, 'logical')
        result = scan_logical(r);
    elseif isa(r, 'java.util.Date')
        result = scan_datetime(r);
    elseif isa(r, 'java.util.List')
        result = scan_list(r);
    elseif isa(r, 'java.util.Map')
        result = scan_map(r);
    else
        error(['Unknown data type: ' class(r)]);
    end;
end

%--------------------------------------------------------------------------
% Transforms Java String to MATLAB char
%
function result = scan_string(r)
    result = char(r);
end

%--------------------------------------------------------------------------
% Transforms Java double to MATLAB double
%
function result = scan_numeric(r)
    result = double(r);
end

%--------------------------------------------------------------------------
% Transforms Java boolean to MATLAB logical
%
function result = scan_logical(r)
    result = logical(r);
end

%--------------------------------------------------------------------------
% Transforms Java Date class to MATLAB DateTime class
%
function result = scan_datetime(r)
    result = DateTime(r);
end

%--------------------------------------------------------------------------
% Transforms Java List to MATLAB cell column running scan(...) recursively
% for all ListS items.
%
function result = scan_list(r)
    result = cell(r.size(),1);
    it = r.iterator();
    ii = 1;
    while it.hasNext()
        i = it.next();
        result{ii} = scan_yaml(i);
        ii = ii + 1;
    end;
end

%--------------------------------------------------------------------------
% Transforms Java Map to MATLAB struct running scan(...) recursively for
% content of every Map field.
% When there is field, which is recognized to be the >import keyword<, an
% attempt is made to import file given by the field content.
%
% The result of import is so far stored as a content of the item named 'import'.
%
function result = scan_map(r)
    it = r.keySet().iterator();
    while it.hasNext()
        next = it.next();
        i = next;
        ich = char(i);
        if iskw_import(ich)
            result.(ich) = perform_import(r.get(java.lang.String(ich)));
        else
            result.(genvarname(ich)) = scan_yaml(r.get(java.lang.String(ich)));
        end;
    end;
    if not(exist('result','var'))
        result={};
    end
end

%--------------------------------------------------------------------------
% Determines whether r contains a keyword denoting import.
%
function result = iskw_import(r)
    result = isequal(r, 'import');
end

%--------------------------------------------------------------------------
% Transforms input hierarchy the usual way. If the result is char, then
% tries to load file denoted by this char. If the result is cell then tries
% to do just mentioned for each cellS item. 
% 
function result = perform_import(r)
    r = scan(r);
    if iscell(r) && all(cellfun(@ischar, r))
        result = cellfun(@load_yaml, r, 'UniformOutput', 0);
    elseif ischar(r)
        result = {load_yaml(r)};
    else
        disp(r);
        error(['Importer does not unterstand given filename. '...
               'Invalid node displayed above.']);
    end;
end
