function res = dataLoad(obj,dp)
    % function res = obj.dataLoad(dp)
    %
    % load data property dp from data file
    % 

    % check if the data property is loaded or not
    if ~obj.status.loaded.data.(dp)
        % data property not laoded yet
        %
        % check if we have a file name for the data file
        % if so, load just the property requested
        dfn = obj.getDataFileName();
        % fixes the issues with the file separator
        % given that we pay a license but matlab  engineers are not able to
        % write software that is platform independent
        dfn = strjoin(strsplit(dfn, {'/','\'}),filesep);
        if ~isempty(dfn) && exist(dfn)
            % ok we got a data file name
            % open it with matfile class
            mfo = matfile(dfn);
            % load the data property requested
            obj.data.(dp) = mfo.(dp);
            % updates def properties
            obj.setDataInfo(dp);
            % marked as loaded
            obj.status.loaded.data.(dp) = 1;
            % delete object
            clear mfo;
        end %if
    end %if
end %function