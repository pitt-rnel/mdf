function [res, message] = dataLoad(obj,dp)
    % function [res, message] = obj.dataLoad(dp)
    %
    % load data property dp from data file
    % 
    % input
    % - dp: (string) nameof the data property
    %
    % output
    % - res: (integer) result of the operation
    %        -2: undefined error
    %        -1: error
    %         0: property not existent
    %         1: property already loaded
    %         2: property loaded
    %
    % - message: (string) error message if needed
    
    % initialize result
    res = -2;
    message = '';
    
    % get mdfConf object handle
    oconf = mdfConf.getInstance();
    
    try
        %check if theproperty exists
        if ~isfield(obj.status.loaded.data,dp)
            res = 0;
        elseif obj.status.loaded.data.(dp)
            res = 1;
        else
            % data property not loaded yet
            %
            if oconf.isCollectionData('MATFILE')
                % data is saved in matfile
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
                    % delete object
                    clear mfo;
                end %if


            elseif oconf.isCollectionData('DATABASE')
                % database only mode
                %
                % object is not loaded yet
                %
                % retrieves database object
                odb = mdfDB.getInstance();
                
                % load data property from db
                mdf_data = odb.find( ...
                    ['{ "mdf_def.mdf_uuid" : "' obj.uuid '" }'], ...
                    ['{ "' dp '" : 1}'] ...
                    );
                % transfer data to object
                % load the data property requested
                % find returns a cell array, given the type of query that we run
                % we know that there is only one document matching it
                %
                % check if we need to flip the cell array
                ds1 = size(mdf_data{1}.(dp));
                ds2 = size(mdf_data{1}.(dp)');
                if ( all(all(obj.mdf_def.mdf_data.(dp).mdf_size(:) == ds1(:))) )
                    obj.data.(dp) = mdf_data{1}.(dp);
                elseif ( all(all(obj.mdf_def.mdf_data.(dp).mdf_size(:) == ds2(:))) )
                    obj.data.(dp) = mdf_data{1}.(dp)';
                else
                    throw(MException('mdfObj:dataLoad','Inconsistency in data size'));
                end %if
            else
                throw(MException('mdfObj:dataLoad','Unrecognized Data Collection'));
            end %if
            
            % updates def properties
            obj.setDataInfo(dp);
            % marked as loaded
            obj.status.loaded.data.(dp) = 1;
            res = 2;
        end %if
    catch e
        res = -1;
        message = e.message;
    end %try/catch
    
end %function
