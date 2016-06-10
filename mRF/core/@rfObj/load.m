function outdata = load(indata)
    % function outdata = rfObj.load(indata)
    %
    % load data and metadata from file or db and return an RF object fully populated
    %
    % input:
    %   indata = single string or structure with one of the following fields
    %   - uuid   : if this field is specified, loads the object defined by this uuid
    %              uuid takes precedence over any other field
    %   - file   : if this field is defined, loads the object defined in the file itself
    %              file takes precedence over everything other field, after uuid
    %   - <type> : object type. users can specify a condition for a specific metadata fields
    %              each condition will be applied in AND with the others.
    %              if there are multiple values for each conditions, each value with be applied in OR
    %
    %            If indata is a string, it will be converted to a structure internally and the 
    %            input value will be assigned to uuid and file
    %
    % output 
    %   outdata = RF object instance fully populated

    % check if we got a string in input
    if isa(indata,'char')
         indata = struct( ...
             'uuid', indata, ...
             'file', indata);
    end %if

    % let's check if indata is a struct
    if ~isa(indata,'struct')
        disp('rfObj.load: input data has to be a structure or a string');
    end %if

    % initialize temp rf structure and output
    outdata = [];
    rf_data = [];

    % retrieve handler to db and manage class
    odb = rfDB.getInstance();
    om = rfManage.getInstance();

    % let's check if we have uuid field
    if isfield(indata,'uuid')
        % check if object is already loaded
        % retrieve handler
        outdata = om.get(indata.uuid);
        if ~isempty(outdata)
            % object already loaded
            % return back the object in memory
            return;
        end %if

        % object is not loaded yet
        % try the db next
        rf_data = odb.find(['{ "rf_def.rf_uuid" : "' indata.uuid '" }']);
        if isempty(rf_data)
            % no luck through the db
            % trys file
            rf_data = rfObj.fileLoadInfo([indata.uuid '_md.yml']);
        end %if
    end %if

    % if rf_data does not contains anything, next check if we have a file name
    if isempty(rf_data) && isfield(indata,'file')
        % check if the object has been loaded
        % tryig to retrieve it by file name
        % retrieve handler, pass it back and return
        outdata = om.get(indata.file);
        if ~isempty(outdata)
            % object already loaded
            % return back object in memory
            return;
        end %if

        % we could not retrieve the object by file name
        % try to load file
        rf_data = rfObj.fileLoadInfo(indata.file);
        % check if we were successful to load the rf data
        if ~isempty(rf_data)
            % check if object has already been loaded by uuid
            outdata = om.get(rf_data.rf_def.rf_uuid);
            if ~isempty(outdata)
                % object already loaded
                % return back object in memory
                return;
            end %if
        end %if
    end %if

    % if rf_data still does not contains any info, 
    % we check if there is a field named rf_query, that contains a json
    % mongodb query
    if isempty(rf_data) && isfield(indata,'rf_query')
        % runs the query as it is
        rf_data = odb.find(indata.rf_query);
    end %if

    % next we check all the other fields and we use them to 
    % build a query and send it to the db
    if isempty(rf_data)
        tmp1 = indata;
        % remove fields not needed
        if isfield(tmp1,'uuid')
            tmp1 = rmfield(tmp1,'uuid');
        end %if
        if isfield(tmp1,'file')
            tmp1 = rmfield(tmp1,'file');
        end %if
        if isfield(tmp1,'rf_query')
            tmp1 = rmfield(tmp1,'rf_query');
        end %if
        if ~isempty(fields(tmp1))
            % now we are ready to build the json query
            tmp2 = rfDB.prepQuery(tmp1);
            % runs query and hopes for the best
            rf_data = odb.find(tmp2);
        end %if
    end %if

    % if we got here, we have not found the object that we are looking for
    % if rf_data is not empty, we need to create it
    if ~isempty(rf_data)
        % here is the structure that rf_data should have
        % rf_data:
        %  - rf_version: 1 
        %  - rf_metadata: metadata of the object
        %  - rf_def: definition of the object
        %    - rf_type: <object type>
        %    - rf_uuid: <object uuid>
        %    - rf_files: object files
        %      - rf_base: base file name for metadata and data file names
        %      - rf_data: .mat or .h5 file completed with data values
        %                 or struct with file name for each data property
        %      - rf_metadata: .mat or .yml file with just rf_def and rf_metadata
        %    - rf_data: data definition
        %      - rf_fields: <dataProp1>, <dataProp2>, …  list of data properties
        %      - <dataProp1>: 
        %        - rf_size: <size1_dataProp1>, <size2_dataProp1> ...
        %        - rf_mem:  <mem_dataProp1>
        %        - rf_class: <ytpre_dataProp1>
        %      … 
        %    - rf_metadata: constrains or definition regarding metadata
        %                   still a work in progress
        %    - rf_children:
        %      - rf_fields: <child_1>, <child_2>, … list of child properties
        %      - <child_1>:
        %        -
        %          rf_uuid: xxxx
        %          rf_file: <file_path>
        %          rf_type: <class type>
        % 
        %    - rf_parents:
        %      -
        %        rf_uuid: xxxx
        %        rf_file: <file_path>
        %        rf_type: <class type>

        % initialize outdata
        outdata = [];

        % loop on all the object found
        for i = 1:length(rf_data)
            % get object data
            cdata = rf_data{i};

            % create new object
            if length(outdata)<1
                outdata = rfObj();
            else
                outdata(end+1) = rfObj();
            end %if
            % populate it
            % uuid
            outdata(end).uuid = cdata.rf_def.rf_uuid;
            % vuuid
            outdata(end).vuuid = cdata.rf_def.rf_vuuid;
            % file
            %outdata(end).file = cdata.rf_def.rf_files.rf_metadata;
            % type
            outdata(end).type = cdata.rf_def.rf_type;
            % def
            outdata(end).def = cdata.rf_def;
            % metadata
            outdata(end).metadata = cdata.rf_metadata;
            % create place marks for data properties
            for i = 1:length(cdata.rf_def.rf_data.rf_fields)
                field = cdata.rf_def.rf_data.rf_fields{i};
                outdata(end).data.(field) = [];
                outdata(end).status.loaded.data.(field) = 0;
                outdata(end).status.size.data.(field) = 0;
            end %if
            % convert rf_parent if needed
            outdata(end).def.rf_parents = rf.c2s(outdata(end).def.rf_parents);
            % convert each childrens list if needed
            for j = 1:length(outdata(end).def.rf_children.rf_fields)
                % get the field name
                field = outdata(end).def.rf_children.rf_fields{j};
                % convert the field
                outdata(end).def.rf_children.(field) = rf.c2s(outdata(end).def.rf_children.(field));
            end %for
            % convert each link list if needed
            for j = 1:length(outdata(end).def.rf_links.rf_fields)
                % get the field name
                field = outdata(end).def.rf_links.rf_fields{j};
                % convert the field
                outdata(end).def.rf_links.(field) = rf.c2s(outdata(end).def.rf_links.(field));
            end %for
            
            % extract children
            %outdata(i).children = cdata.rf_def.rf_children;
            % extract parents
            %outdata(i).parents = cdata.rf_def.rf_parents;

            % register RF object in memory structures
            om.insert(outdata(end).uuid,outdata(end).getMFN(),outdata(end));
        end %for

        % clear rf data from memory
        clear rf_data;

    end %if
end %function

