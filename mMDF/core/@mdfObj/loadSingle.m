function outdata = loadSingle(indata)
    % function outdata = mdfObj.loadSingle(indata)
    %
    % static method of mdfObj
    % load data and metadata from file, db or json string and return an MDF object fully populated
    %
    % input:
    %   indata = single string containing one of the following options
    %   - uuid   : loads the object defined by this uuid
    %   - file   : loads the object defined in the file itself
    %              file can be yaml or mat format
    %   - json   : loads the object directly defined in the json string
    %              it converts the json string associated to a matlab
    %              struct
    %
    % output 
    %   outdata = mdf object instance fully populated

    
    % initialize temp mdf structure and output
    outdata = [];
    mdf_obj_data = [];

    %
    % check if we have a string
    if ~ischar(indata)
        return;
    end %if

    % check if object is already loaded
    % retrieve handler hoping that that indata contains 
    % a uuid, a file name
    outdata = om.get(indata);
    if ~isempty(outdata)
    	% object already loaded
        % return back the object in memory
        return;
    end %if

    % retrieve handler to db and manage class
    odb = mdfDB.getInstance();
    om = mdfManage.getInstance();

    % let's check if we have an object uuid
    % if we got a uuid, the objecct is not loaded in memeory
    % use try/catch
    try
        % object is not loaded yet
        % try the db next
        mdf_obj_data = odb.find(['{ "mdf_def.mdf_uuid" : "' indata.uuid '" }']);
    catch
        mdf_obj_data = [];
    end %try/catch
    
    % if mdf_data does not contains anything, next check if we have a file name
    if isempty(mdf_obj_data)
    
        % we could not retrieve the object by file name
        % try to load file
        mdf_obj_data = mdfObj.fileLoadInfo(indata);
    end %if
    
    % if mdf_data is still empty, next we check for json string
    if isempty(mdf_obj_data)
        % tried to convert the input string in a matlab struct with json
        % loader
        try
            mdf_obj_data = loadjson(indata);
        catch
            mdf_obj_data = [];
        end %try/catch
    end %if
    

    % if we got here, we have not found the object that we are looking for
    % if mdf_data is not empty, we need to create it
    if ~isempty(mdf_obj_data)
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

        % check if we were successful to load the mdf data
        if ~isempty(mdf_obj_data)
            % check if object has already been loaded by uuid
            outdata = om.get(mdf_obj_data.mdf_def.mdf_uuid);
            if ~isempty(outdata)
                % object already loaded
                % return back object in memory
                return;
            end %if
        end %if


        % initialize outdata
        outdata = mdfObj();
        % mdfObj populate
        outdata.populate(mdf_obj_data);
        
        % clear mdf data from memory
        clear mdf_data;

    end %if
end %function

