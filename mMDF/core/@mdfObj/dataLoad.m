function res = dataLoad(obj,dp)
    % function res = obj.dataLoad(dp)
    %
    % load data property dp from data file
    % 

    % check if the data property is loaded or not
    if ~obj.status.loaded.data.(dp)
        % data property not loaded yet
        %
        % it loads it from the database document
        % use try/catch
        try
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
            % updates def properties
            obj.setDataInfo(dp);
            % marked as loaded
            obj.status.loaded.data.(dp) = 1;
            res = 1;
        catch
            res = 0;
        end %try/catch
    end %if
end %function
