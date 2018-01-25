function res = resetFiles(obj)
    % function res = obj.resetFiles(indata)
    %
    % reset file names.
    %
    
    res = false;
    
    %  reset all the files for hte file names
    obj.mdf_def.mdf_files.mdf_base = '';
	obj.mdf_def.mdf_files.mdf_data = '';
    obj.mdf_def.mdf_files.mdf_metadata = '';

    res = true;
end %function