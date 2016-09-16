function [uuid, object] = getUuidAndObject(indata)
    % function [uuid, object] = mdf.getUuidAndObject(indata);
    %
    % given the input (uuid or mdfObj), it returns both uuid and object
    %
    % input
    %  - indata (string or mdfObj): it can be the mdfObj instance or the
    %                               uuid of the object
    %
    % output
    %  - uuid   (string) : object uuid
    %  - object (mdfObj) : handle to the mdfObj
    %
    
    switch class(indata)
        case 'mdfObj'
            % input is an mdfObj instance
            % get uuid and check if it needs to be inserted in memory
            uuid = indata.uuid;
            
        case 'char'
            % input is a string, so we assume that it is the uuid of the
            % object
            uuid = indata;
            
        otherwise
            % if we get here, there is something wrong
            % we do not accept anything else in input
            throw( ...
                MException( ...
                    'mdf:getUuidAndObject:10', ...
                    ['Invalid input']));
    end %switch
    
    % load the object, just to be sure
    object = mdf.load(uuid);
    % check if we got an object
    if ~isa(object,'mdfObj')
        % no luck, something went wrong
        throw( ...
        	MException( ...
                'mdf:getUuidAndObject:20', ...
                ['Object not found or invalid']));
    end %if
end %function