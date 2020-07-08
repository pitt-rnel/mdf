function [res, stats, raw] = validateSchema(obj)
    % function [res, stats, raw] = obj.validateSchema()
    %
    % check the data collection for the schema.
    % Output
    % - res     : (boolean) True if all the mdf objects of the same mdf type
    %             contains the same fields, false otherwise
    % - stats  : (struct) structure with all the information about the schema
    %             .fieldConsistency     = (boolean) true if all the fields
    %                                     are present in 100% of the mdf_type objects assigned to
    %             .valueTypeConsistency = (boolean) true if each fields
    %                                     has always the same value type
    %             .schema[]
    %              .mdf_type = (string) mdf type found
    %              .count    = (integer) instances found of this mdf_type
    %                          in this collection
    %              .percent  = (float) percentage of objects of this
    %                          mdf_type over the entire collection
    %              .mdf_metadata[]
    %               .property = (string) metadata property name
    %               .count    = (integer) instances found of this mdf_type
    %                           in this collection
    %               .percent  = (float) percentage of objects of this mdf_type 
    %                           that have this metadata field
    %               .data_type[]
    %                .type    = (string) data type of the value of this field
    %                .count   = (integer) instances found for this metatada
    %                           property withi this data type
    %                .percent = (float) percentage of this metadata field
    %                           that are of this data type
    % - raw     : (struct) the data returned directly from the map reduce
    %             operation on the database
    % 

    % convert validation map reduce commands to BSON document
    validateSchemaCommand = obj.toBsonDocument(obj.jsSchemaFunction);
    
    % -----------------------
    % Run map/reduce with server side mdf schema function 
    %
    mrJsonRes = obj.db.runCommand(validateSchemaCommand);
    
    % convert results in matlab structure
    mrRaw = mdf.fromJson(char(mrJsonRes.toJson()));
    % extract just the counts
    mrCounts = cell2mat({mrRaw.results(:).value});
    % number of documents in collection
    docNumber = mrRaw.counts.input;
  
    % initialize schema to mdf_type counts
    schema = arrayfun( ...
        @(item)( ...
            struct( ...
                'mdf_type',item.mdf_type, ...
                'count',item.count, ...
                'percent', item.count / docNumber)), ...
        mrCounts( ...
            strcmp({mrCounts.value_type},'all') & ...
            strcmp({mrCounts.data_type},'all') & ...
            strcmp({mrCounts.field},'all') ...
        ));
    
    % build stats for each metedata fields
    for i = 1:length(schema)
        % get mdf_type
        mdf_type = schema(i).mdf_type;
        % extract total fields count for current mdf
        schema(i).mdf_metadata = arrayfun( ...
            @(item)( ...
                struct( ...
                    'mdf_property',item.field, ...
                    'count',item.count, ...
                    'percent', item.count / schema(i).count, ...
                    'property_type', 'metadata')), ...
            mrCounts( ...
                strcmp({mrCounts.mdf_type},mdf_type) & ...
                strcmp({mrCounts.value_type},'all') & ...
                strcmp({mrCounts.data_type},'metadata')));
            
        % for each property extract data types
        for j = 1:length(schema(i).mdf_metadata)
            % get mdf_property
            mdf_property = schema(i).mdf_metadata(j).mdf_property;
            % extract all the different data types for this property
            schema(i).mdf_metadata(j).value_type = arrayfun( ...
                @(item)( ...
                    struct( ...
                        'value_type',item.value_type, ...
                        'count',item.count, ...
                        'percent', item.count / schema(i).mdf_metadata(j).count)), ...
                mrCounts( ...
                    strcmp({mrCounts.mdf_type},mdf_type) & ...
                    ~strcmp({mrCounts.value_type},'all') & ...
                    strcmp({mrCounts.field},mdf_property) & ...
                    strcmp({mrCounts.data_type},'metadata')));
        end %for
    end %for
    
    %
    % check if schema is consistent
    mdf_metadata_all = [schema(:).mdf_metadata];
    fieldConsistency = all([mdf_metadata_all.percent] == 1);
    %
    % value type consistency
    valueTypeConsistency = all(arrayfun(@(item)( length(item.value_type) ),mdf_metadata_all));
    
    %
    % prepare results
    res = fieldConsistency & valueTypeConsistency;

    if nargout > 1
        % prepare schema results
        stats =  struct( ...
            'fieldConsistency', fieldConsistency, ...
            'valueTypeConsistency', valueTypeConsistency, ...
            'schema', schema);        
    end %if
    
    if nargout > 2
        % provide raw results
        raw = mrRaw;
    end %if

end %function
