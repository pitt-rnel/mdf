function outQuery = prepQuery(inquery)
    % function outQuery = rfDB.prepQuery(inquery)
    %
    % prepare json query from matlab struct query
    % every field in the structure is considered a query field
    % except the ones which names start with rf_.
    % those are considered parameters for this function
    %
    % argument fields
    % - rf_exact: if true, take the all struct and convert it to json exactly as it is.
    %             if false, aggregate levels.
    %             please refer to mongodb find command for more details
    %

    % check for input arguments and remove rf_ fields
    % check if the field is one the recognized input parameters
    exact = 0;
    try
        exact = inquery.rf_exact;
        inquery = rmfields(inquery,'rf_exact');
    catch
        % nothing to do
        exact = 0;
    end %try/catch

    % list fields in inquery
    lf = fields(inquery);
    % initialize internal query
    iq = inquery;
    % structure with rf fields
    rff = {};
    % remove rf_fields
    for i = 1:length(lf)
         % find rf_ in field name
         pos = strfind(lf{i},'rf_');
         if ~isempty(pos) && pos==1
             % configuration field
             % transfer to dedicated structure
             rff{end+1} = lf{i};
             % remove it
             iq = rmfield(iq,lf{i});
         end %if
    end %for
    % we assume that we are doing a query on metadata
    iq = struct();
    if ~isempty(fields(iq))
        iq.rf_metadata = iq;
    end %if
    % check if there is any rf fields that needs to be added
    rff = intersect(rff,{'rf_type','rf_uuid','rf_vuuid'});
    rf_def = struct();
    for i = 1:length(rff)
        rf_def.(rff{i}) = inquery.(rff{i});
    end %if
    if ~isempty(fields(rf_def))
        iq.rf_def = rf_def;
    end %if
        
    if exact
        % user asked to transform query as it is
        outQuery = savejson('',iq);
    else
        % let's do conversion with aggregation and all that jazz
        outQuery = ['{ ' recPrepQuery(iq) ' }'];
    end %if
end %function

function output = recPrepQuery(input,iprefix)
    if nargin <= 1
        iprefix = '';
    end %if
    % initialize output
    output = '';
    % check if it is a struct or not
    if isa(input,'struct')
        % we have a structure
        % list fields
        fl = fields(input);
        % initialize output
        output = '';
        % loop on all fields
        for i = 1:length(fl)
            % get field name
            field = fl{i};
            % prepare prefix for next level
            nlprefix = [iprefix '.' field];
            % remove . at the beginning if needed
            nlprefix(find(strfind(nlprefix,'.')==1)) = [];
            % recursively called itself
            tmp1 = recPrepQuery(input.(field),nlprefix);
            % append to output
            output = [ output ' , ' tmp1 ];
        end %for 
        output = regexprep(output,'^ *, ',' ');
    elseif isa(input,'cell')
        if length(input) > 1
            % prepare output
            output = '"$or" : [';
            % create an or statement for this element
            for i = 1:length(input)
                % call itself on the element
                tmp1 = recPrepQuery(input{i},iprefix);
                % append element to output
                output = [ output ',{' tmp1 '}'];
            end %for
            output = [output ']'];
            output = regexprep(output,'\[,\{','[{');
        else
            % cell array with only one element
            output = recPrepQuery(input{1}, iprefix);
        end %if
    elseif isa(input,'char')
        output = ['"' iprefix '" : "' input '"'];
    elseif isnumeric(input)
        if length(input)>1
            % prepare output
            output = '"$or" : [';
            % create an or statement for this element
            for i = 1:length(input)
                % call itself on the element
                tmp1 = recPrepQuery(input(i),iprefix);
                % append element to output
                output = [ output ',{' tmp1 '}'];
            end %for
            output = [output ']'];
            output = regexprep(output,'\[,\{','[{');            
        else
            output =  ['"' iprefix '" : ' num2str(input) ];
        end %if
    else
        % nothing we recognize, we pass back the value as it is
        % and hope for the best
        output =  ['"' iprefix '" : "' input '"'];
    end %if
end %function
