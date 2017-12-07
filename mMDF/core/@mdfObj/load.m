function outdata = load(indata)
    % function outdata = mdfObj.load(indata)
    %
    % load data and metadata from file or db and return an RF object fully populated
    %
    % input:
    %   indata = single string or structure with one of the following fields
    %   - uuid    : if this field is specified, loads the object defined by this uuid
    %               uuid takes precedence over any other field
    %   - file    : if this field is defined, loads the object defined in the file itself
    %               file takes precedence over everything other field, after uuid
    %   - json    : if this field is defiend, loads the object directly
    %               converting the json string associated to object
    %   - <field> : field values. Users can specify a condition for a specific metadata fields.
    %               each condition will be applied in AND with the others.
    %               if there are multiple values for each conditions, each value with be applied in OR
    %
    %               If indata is a string, it will be converted to a structure internally and the 
    %              input value will be assigned to uuid and file
    %
    % output 
    %   outdata = MDF object instance fully populated

    % check if we got a string in input
    if isa(indata,'char')
         indata = struct( ...
             'uuid', indata, ...
             'file', indata, ...
             'json', indata);
    end %if

    % let's check if indata is a struct
    if ~isa(indata,'struct')
        disp('mdfObj.load: input data has to be a structure or a string');
    end %if

    % initialize temp mdf structure and output
    outdata = [];
    mdf_data = [];

    % retrieve handler to db and manage class
    odb = mdfDB.getInstance();
    om = mdfManage.getInstance();

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

        % use try/catch
        try
            % object is not loaded yet
            % try the db next
            mdf_data = odb.find(['{ "mdf_def.mdf_uuid" : "' indata.uuid '" }']);
            if isempty(mdf_data)
                % no luck through the db
                % trys file
                mdf_data = mdfObj.fileLoadInfo([indata.uuid '_md.yml']);
            end %if
        catch
            mdf_data = [];
        end %try/catch
    end %if

    % if mdf_data does not contains anything, next check if we have a file name
    if isempty(mdf_data) && isfield(indata,'file')
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
        mdf_data = mdfObj.fileLoadInfo(indata.file);
        % check if we were successful to load the mdf data
        if ~isempty(mdf_data)
            % check if object has already been loaded by uuid
            outdata = om.get(mdf_data.mdf_def.mdf_uuid);
            if ~isempty(outdata)
                % object already loaded
                % return back object in memory
                return;
            end %if
        end %if
    end %if
    
    % if mdf_data is still empty, next we check for json string
    if isempty(mdf_data) && isfield(indata,'json')
        % convert everything to a cell array
        if isa(indata.json,'char')
            indata.json = {indata.json};
        end %if
        % tries to convert json string to matlab structure
        % also checks if ther are all the fields needed
        try
            mdf_data = cellfun(@(x) loadjson(x), indata.json,'UniformOutput', 0);
        catch
            % an error occured. returning empty handed
            return;
        end %try/catch
    end %if
    

    % if mdf_data still does not contains any info, 
    % we check if there is a field named mdf_query, that contains a json
    % mongodb query
    if isempty(mdf_data) && isfield(indata,'mdf_query')
        % runs the query as it is
        mdf_data = odb.find(indata.mdf_query);
    end %if

    % next we check all the other fields and we use them to 
    % build a query and send it to the db
    if isempty(mdf_data)
        tmp1 = indata;
        % remove fields not needed
        if isfield(tmp1,'uuid')
            tmp1 = rmfield(tmp1,'uuid');
        end %if
        if isfield(tmp1,'file')
            tmp1 = rmfield(tmp1,'file');
        end %if
        if isfield(tmp1,'mdf_query')
            tmp1 = rmfield(tmp1,'mdf_query');
        end %if
        if ~isempty(fields(tmp1))
            % now we are ready to build the json query
            tmp2 = mdfDB.prepQuery(tmp1);
            % runs query and hopes for the best
            mdf_data = odb.find(tmp2);
        end %if
    end %if

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
        
        % check if mdf_data is a cell
        % if it is not a cell, most likely we loaded data from a single file
        % converts it to a cell
        if ~iscell(mdf_data)
            mdf_data = {mdf_data};
        end %if

        % loop on all the object found
        for i = 1:length(mdf_data)
            % get object data
            cdata = mdf_data{i};

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
            % uuid
            outdata(end).uuid = cdata.mdf_def.mdf_uuid;
            % vuuid
            outdata(end).vuuid = cdata.mdf_def.mdf_vuuid;
            % file
            %outdata(end).file = cdata.mdf_def.mdf_files.mdf_metadata;
            % type
            outdata(end).type = cdata.mdf_def.mdf_type;
            % def
            outdata(end).mdf_def = cdata.mdf_def;
            % metadata
            outdata(end).metadata = cdata.mdf_metadata;
            % create place marks for data properties
            for q = 1:length(cdata.mdf_def.mdf_data.mdf_fields)
                field = cdata.mdf_def.mdf_data.mdf_fields{q};
                if isstruct(cdata.mdf_def.mdf_data.(field).mdf_mem)
                    outdata(end).mdf_def.mdf_data.(field).mdf_mem = str2double(cdata.mdf_def.mdf_data.(field).mdf_mem.x0x24_numberLong);
                end
                outdata(end).data.(field) = [];
                outdata(end).status.loaded.data.(field) = 0;
                outdata(end).status.size.data.(field) = 0;
            end %if
            % convert mdf_parent if needed
            outdata(end).mdf_def.mdf_parents = mdf.c2s(outdata(end).mdf_def.mdf_parents);
            % convert each childrens list if needed
            for j = 1:length(outdata(end).mdf_def.mdf_children.mdf_fields)
                % get the field name
                field = outdata(end).mdf_def.mdf_children.mdf_fields{j};
                % convert the field
                outdata(end).mdf_def.mdf_children.(field) = mdf.c2s(outdata(end).mdf_def.mdf_children.(field));
            end %for

            % convert each link list if needed
            for j = 1:length(outdata(end).mdf_def.mdf_links.mdf_fields)
                % get the field name
                field = outdata(end).mdf_def.mdf_links.mdf_fields{j};
                % convert the field
                outdata(end).mdf_def.mdf_links.(field) = mdf.c2s(outdata(end).mdf_def.mdf_links.(field));
            end %for
            
            % extract children
            %outdata(i).children = cdata.mdf_def.mdf_children;
            % extract parents
            %outdata(i).parents = cdata.mdf_def.mdf_parents;

            % register RF object in memory structures
            om.insert(outdata(end).uuid,outdata(end).getMFN(),outdata(end));
        end %for

        % clear mdf data from memory
        clear mdf_data;

    end %if
end %function

