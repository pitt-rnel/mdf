function outdata = loadMulti(indata)
    % function outdata = mdfObj.load(indata)
    %
    % static function to load multiple mdf objects from different sources
    %
    % input:
    %   indata = input data can be any of the following options
    %    * (string) the value can be a uuid, file name, a json string
    %            or a mongo query.
    %    * (struct) with one of the following fields:
    %     - mdf_uuid   : (optional, string or cell of strings)
    %                    loads the object defined by the uuids listed
    %     - mdf_file   : (optional, string or cell of strings)
    %                    loads the object defined in the files listed
    %     - mfd_json   : (optional, string or cell of strings)
    %                    loads objects directly from the json string listed
    %                    each json string is converted to a matlab struct and than loaded as mdf object
    %     - mdf_query  : (optional, string) this string a mongo query that gets passed
    %                    directly to the database
    %     - <field>    : (optional, string) users can specify a condition for a specific metadata fields
    %                    each condition will be applied in AND with the others.
    %                    if there are multiple values for each conditions, each value with be applied in OR
    %                    Fields are considered only if none of hte previous fields are specified   
    %    * (cell of strings) each value can be either uuid, file name or json 
    %             loop through all of them and try to load the matching
    %             object with the best option. More time consuming
    %
    % output 
    %   outdata = MDF object instance fully populated

    % initialize output
    outdata = [];
    
    % list of mdf structs to be loaded as mdf object
    mdf_data = [];

	% retrieve handler to db and manage class
    odb = mdfDB.getInstance();
    om = mdfManage.getInstance();

    % check what we have in input
    switch (class(indata))
        case 'char'
            % try to get mdf object data structure to be injected in mdf
            % object
            mdf_data = mdfObj.loadMdfData(indata);

        case 'struct'
            % struct input
            %
            % first load data from uuid
            if isfield(indata,'mdf_uuid')
                % if field is a single string, transform it in cell
                if isa(indata.uuid,'char')
                    indata.mdf_uuid = { indata.mdf_uuid };
                end %if
                % load object by uuid
                mdf_data_t1 = odb.find( ...
                    [ ...
                        '{ "mdf_def.mdf_uuid" : { $in ["' ...
                        strjoin(indata.mdf_uuid,'", "') ...
                        '"] } }']);
            end %if

            % than from files
            if isfield(indata,'mdf_file')
                % if field is a single string, transform it in cell
                if isa(indata.mdf_file,'char')
                    indata.mdf_file = { indata.mdf_file };
                end %if
                mdf_data_t2 = cellfun( ...
                    @(x) mdfObj.fileLoadInfo(x), ...
                    indata.mdf_file, ...
                    'UniformOutput', 1);
            end %if
        
            % than from json
            if isfield(indata,'mdf_json')
                % if field is a single string, transform it in cell
                if isa(indata.mdf_json,'char')
                    indata.mdf_json = { indata.mdf_json };
                end %if
                mdf_data_t3 = cellfun( ...
                    @(x) mdfObj.loadjson(x), ...
                    indata.mdf_json, ...
                    'UniformOutput', 1);
            end %if
            
            % than from mongo query
            if isfield(indata,'mdf_query')
                % if field is a single string, transform it in cell
                if isa(indata.mdf_query,'char')
                    indata.mdf_query = { indata.mdf_query };
                end %if
                mdf_data_t4 = cellfun( ...
                    @(x) odb.find(x), ...
                    indata.mdf_query, ...
                    'UniformOutput', 1);
            end %if
            
            % puts together all the results
            mdf_data = { mdf_data_t1{:}, mdf_data_t2{:}, mdf_data_t3{:}, mdf_data_t4{:} };
            
            % if everything else fails and we still have fields
            % tries to build a query
            if isempty(mdf_data)
                temp1 = indata;
                % remove fields not needed
                if isfield(temp1,'mdf_uuid')
                    temp1 = rmfield(temp1,'mdf_uuid');
                end %if
                if isfield(temp1,'mdf_file')
                    temp1 = rmfield(temp1,'mdf_file');
                end %if
                if isfield(temp1,'mdf_json')
                    temp1 = rmfield(temp1,'mdf_json');
                end %if
                if isfield(temp1,'mdf_query')
                    temp1 = rmfield(temp1,'mdf_query');
                end %if
                if ~isempty(fields(temp1))
                    % now we are ready to build the json query
                    temp2 = mdfDB.prepQuery(temp1);
                    % runs query and hopes for the best
                    mdf_data = odb.find(temp2);
                end %if
            end %if
            
        case 'cell'
            % cell input
            %
            % we have no other option that loop on all the elements of the
            % array and load them one by one
            mdf_data = cellfun( @(x) mdfObj.loadMdfData(x),indata,'UniformOutput',1);
            % remove empty elements
            mask = cellfun( @(x) isempty(x), mdf_data);
            mdf_data(mask) = [];
    end % switch
    
    % if we got here, we have not found the object that we are looking for
    % if mdf_data is not empty, we need to create it
    if ~isempty(mdf_data)
        % here is the structure that mdf_data should have
        % mdf_data:
        %  - mdf_version: 1 
        %  - mdf_metadata: metadata of the object
        %  - mdf_def: definition of the object
        %    - mdf_type: <object type>
        %    - mdf_uuid: <object uuid>
        %    - mdf_files: object files
        %      - mdf_base: base file name for metadata and data file names
        %      - mdf_data: .mat or .h5 file completed with data values
        %                 or struct with file name for each data property
        %      - mdf_metadata: .mat or .yml file with just mdf_def and mdf_metadata
        %    - mdf_data: data definition
        %      - mdf_fields: <dataProp1>, <dataProp2>, …  list of data properties
        %      - <dataProp1>: 
        %        - mdf_size: <size1_dataProp1>, <size2_dataProp1> ...
        %        - mdf_mem:  <mem_dataProp1>
        %        - mdf_class: <ytpre_dataProp1>
        %      … 
        %    - mdf_metadata: constrains or definition regarding metadata
        %                   still a work in progress
        %    - mdf_children:
        %      - mdf_fields: <child_1>, <child_2>, … list of child properties
        %      - <child_1>:
        %        -
        %          mdf_uuid: xxxx
        %          mdf_file: <file_path>
        %          mdf_type: <class type>
        % 
        %    - mdf_parents:
        %      -
        %        mdf_uuid: xxxx
        %        mdf_file: <file_path>
        %        mdf_type: <class type>

        % initialize outdata
        outdata = [];

        % loop on all the object found
        for i = 1:length(mdf_data)
            % get object data
            cdata = mdf_data{i};

            % check if we have already an object in the  list
            if isa(cdata,'mdfObj')
                % use the one already loaded
                if length(outdata) < 1
                    outdata = cdata;
                else
                    outdata(end+1) = cdata;
                end %if
                % skip to the next
                continue;
            end %if               
            
            % check if the object has been already loaded
            otemp1 = om.get(cdata.mdf_def.mdf_uuid);
            if ~isempty(otemp1)
                % object already loaded in memory
                % use the one already loaded
                if length(outdata) < 1
                    outdata = otemp1;
                else
                    outdata(end+1) = otemp1;
                end %if
                % skip to next object
                continue;
            end %if
            
            % object not loaded, goes ahead and loads it
            %
            % create new object
            if length(outdata)<1
                outdata = mdfObj();
            else
                outdata(end+1) = mdfObj();
            end %if
            % populate it
            outdata(end).populate(cdata);
        end %for

        % clear mdf data from memory
        clear mdf_data;

    end %if
end %function

