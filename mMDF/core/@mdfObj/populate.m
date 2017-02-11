function res = populate(obj,indata)
    % function res = obj.load(obj,indata)
    %
    % populate obj with data and metadata passed in indata
    % only one object definition is allowed as an input
    %
    % structure for the mdf object definition is as follow
    % mdf object definition:
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
    %
    % input:
    %   indata = single json string or matlab structure with mdf object definition
    %
    % output 
    %   res = true if object has been populated
    %

    % set return value
    res = 0;

    % check if indata is a string
    if isa(indata,'char')
         % we assume that we received the json string with the object definition
         indata = loadjson(indata);
    end %if

    % let's check if indata is a struct
    if ~isa(indata,'struct')
        disp('mdfObj.load: input data has to be a structure or a string');
    end %if

    % retrieve handler to db and manage class
    %odb = mdfDB.getInstance();
    om = mdfManage.getInstance();

    % let's check if indata structure has all the required fields
    % at least at the first level
    %
    % mdf_version
    if ~isfield(indata,'mdf_version') && ~isnumber(indata.mdf_version)
        indata.mdf_version = 1;
    end %if
    %
    % mdf_def
    if ~isfield(indata,'mdf_def') && ~isstruct(indata.mdf_def)
        return;
    end %if
    %
    % mdf_def.mdf_type
    if ~isfield(indata.mdf_def,'mdf_type') && ~isa(indata.mdf_def.mdf_type,'char')
        return;
    end %if
    %
    % mdf_def.mdf_uuid
    if ~isfield(indata.mdf_def,'mdf_uuid') && ~isa(indata.mdf_def.mdf_uuid,'char')
        return;
    end %if
    %
    % mdf_metadata
    if ~isfield(indata,'mdf_metadata') && ~isstruct(indata.mdf_metadata)
        return;
    end %if
 
    % check if this object has already been loaded in memory
    if ~isempty(om.get(indata.mdf_def.mdf_uuid))
        % object already loaded in memory
        % does not populate it
        return;
    end %if

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

            
    % populate it
    % uuid
    obj.uuid = indata.mdf_def.mdf_uuid;
    % vuuid
    obj.vuuid = indata.mdf_def.mdf_vuuid;
    % type
    obj.type = indata.mdf_def.mdf_type;
    % def
    obj.mdf_def = indata.mdf_def;
    % metadata
    obj.metadata = indata.mdf_metadata;
    % create place marks for data properties
    for i = 1:length(indata.mdf_def.mdf_data.mdf_fields)
        field = indata.mdf_def.mdf_data.mdf_fields{i};
        obj.data.(field) = [];
        obj.status.loaded.data.(field) = 0;
        obj.status.size.data.(field) = 0;
    end %if
    % convert mdf_parent if needed
    obj.mdf_def.mdf_parents = mdf.c2s(obj.mdf_def.mdf_parents);
    % convert each childrens list if needed
    for j = 1:length(obj.mdf_def.mdf_children.mdf_fields)
        % get the field name
        field = obj.mdf_def.mdf_children.mdf_fields{j};
        % convert the field
        obj.mdf_def.mdf_children.(field) = mdf.c2s(obj.mdf_def.mdf_children.(field));
    end %for
    % convert each link list if needed
    for j = 1:length(obj.mdf_def.mdf_links.mdf_fields)
        % get the field name
        field = obj.mdf_def.mdf_links.mdf_fields{j};
        % convert the field
        obj.mdf_def.mdf_links.(field) = mdf.c2s(obj.mdf_def.mdf_links.(field));
    end %for
            
    % register RF object in memory structures
    om.insert(obj.uuid,obj.getMFN(),obj);

    % return success
    res = 1;
end %function

