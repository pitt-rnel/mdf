function res = setFiles(obj,indata)
    % function res = obj.setFiles(indata)
    %
    % set files where data is going to be saved
    % if indata is a string, it is assumed that it is the base path used to
    % build data and metadata file names
    % if it is a structure, it has to contain the following fields:
    %  base, data, metadata
    % In this case base is not used. Data is the file name for the .mat
    % data file, whgile metadata is the file name of the yaml metadata file
    
    res = false;
    
    switch class(indata)
        case 'char'
            % we got base path
            obj.mdf_def.mdf_files.mdf_base = indata;
            
            % set output
            res = obj.getFiles();
            
        case 'struct'
            % we got whole of it: base, data and metadata
            if isfield(indata,'base')
                obj.mdf_def.mdf_files.mdf_base = indata.base;
            else
                obj.mdf_def.mdf_files.mdf_base = '';
            end %if
            obj.mdf_def.mdf_files.mdf_data = indata.data;
            obj.mdf_def.mdf_files.mdf_metadata = indata.metadata;

            % set output
            res = getFiles();

    end %switch
    
end %function