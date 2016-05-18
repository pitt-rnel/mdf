function object  = getByUUID(uuid)
    % function outdata = getByUUID(uuid)
    %
    % search the db for an entry with the given uuid,
    % or a file for with named equal to <uuid>.xml/mat/h5
    %

    % access global RF data structure
    global RF

    % initialize output
    object = nan;

    % try to find uuif in the list of loaded uuid
    index = strcmp(RF.uuid,uuid);

    if ~empty(index)
        if max(size(index)) == 1
            object = RF.objects[index];
        else
            % we throw and error, there should not be multiple object with the same uuid
            throw MException('RL:getByUUID',['Error: multiple object found with same uuid ' uuid])
        end %if
    end %if

end %function
