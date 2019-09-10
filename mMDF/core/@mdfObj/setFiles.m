function res = setFiles(obj,indata,reset)
    % function res = obj.setFiles(indata,reset)
    %
    % set files where data is going to be saved
    %
    % INPUT
    % - indata : (string) user has specified the base path used to
    %            build data and metadata file names
    %            (struct) user has passed a structure in input. 
    %            It has to contain the following fields:
    %            * base, 
    %            * data, 
    %            * metadata
    %            In this case base is not used, but saved anyway. 
    %            Data is the file name for the .mat data file, 
    %            while metadata is the file name of the yaml metadata file
    %
    % - reset : (boolean) if indata is a string, indicate that the file
    %           names should be cleared before performing the assignment.
    %           it is ignored owtherwise
    
    res = false;
    
    switch class(indata)
        case 'char'
        	% check if we need to reset
            if nargin > 2 && reset
                obj.resetFiles();
            end %if

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
            res = obj.getFiles();

    end %switch
    
end %function