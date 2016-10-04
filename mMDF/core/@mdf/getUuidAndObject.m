function [uuid, object] = getUuidAndObject(indata)
    % function [uuid, object] = mdf.getUuidAndObject(indata);
    %
    % given the input (uuid or mdfObj), it returns both uuid and object
    %
    % input
    %  - indata (string or mdfObj): 
    %           it can be the mdfObj instance or the uuid of the object.
    %           if uuid is passed, the object has to be already saved and 
    %           registered in the memory management object, because 
    %           we need to be able to load it by uuid
    %           if mdfObj object is passed, the object can be a new one 
    %           and not already saved in the db. This allow looping and 
    %           creation of multiple object and relations before they are 
    %           saved in the db
    % 
    % output
    %  - uuid   (string) : object uuid
    %  - object (mdfObj) : handle to the mdfObj
    %
      
    switch class(indata)
        case 'mdfObj'
            % input is an mdfObj instance
            % get uuid from the object
            uuid = indata.uuid;
            % check if uuid is a string and not empty
            if ~ischar(uuid) || isempty(uuid)
                throw( ...
                     MException( ...
                         'mdf:getUuidAndObject:10', ...
                         ['Invalid object uuid']));
            end %if
            % set object 
            object = indata;

        case 'char'
            % input is a string, so we assume that it is the uuid of the
            % object
            uuid = indata;
            
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

        otherwise
            % if we get here, there is something wrong
            % we do not accept anything else in input
            throw( ...
                MException( ...
                    'mdf:getUuidAndObject:30', ...
                    ['Invalid input']));
    end %switch

    % check output 
    if ~ischar(uuid) || isempty(uuid) || ~isa(object,'mdfObj')
            throw( ...
                MException( ...
                    'mdf:getUuidAndObject:40', ...
                    ['Invalid output']));
    end %if
    
end %function

