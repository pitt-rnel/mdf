function [res, messages] = isValidConf(obj,conf)
    % function res = obj.isValidConf(conf)
    %
    % check if the conf is a valid one for our class
    %
    % input
    %  conf = (struct)
    %    - host       = (string) host name where the database is storage
    %    - port       = (number) port number where the database is listening
    %    - database   = (string) name of the database
    %    - collection = (string) name of the collection
    %    - connect    = (boolean) if we need to actually connect to the
    %                   database when configurating. Optional. 
    %                   Default: false
    %
    % output
    %   res      = (boolean) True if conf is valid
    %   messages = (cell of strings) list of errors encountered
    %
    
    % list of messages
    messages = {};
    
    % initialize output
    res = true;
    
    % find which field is missing
    missingFields = setdiff(obj.fieldsRequired,fields(conf));
    if ~isempty(missingFields)
        messages{end+1} = ['Missing ' length(missingFields) ' fields'];
        res = false;
    end %if
    
    fl = fields(obj.fieldInfo);
    for fi = 1:length(fl)
        field = fl{fi};
        if ~isfield(conf,field) 
            if obj.fieldInfo.(field).required
                messages{end+1} = [ ...
                    'Field ' field ' missing'];
                res = false;
            end %if
        elseif ~isa(conf.(field),obj.fieldInfo.(field).type)
            messages{end+1} = [ ...
                'Field ' field ...
                ' not of the correct type (Current:' class(conf.(field)) ...
                ' - Expected:' obj.fieldInfo.(field).type ')'];
            res = false;
        end %if
    end %for
    
end %function