classdef rfObj < handle
    %
    % class: rfObj
    % Rnel Data Framework
    % class container for raw data and to implement a hierarchical but open 
    % data structure
    %
    
    properties (SetObservable)
        type = '';
        uuid = '';
        vuuid = '';
        created = '';
        modified = '';
        data = struct();
        metadata = struct();
        %children = struct();
        %parents = struct();
        def = struct( ...
            'rf_type', '', ...
            'rf_uuid', '', ...
            'rf_vuuid', '', ...
            'rf_created', '', ...
            'rf_modified', '', ...
            'rf_files', struct(), ...
            'rf_data', struct(), ...
            'rf_metadata', struct(), ...
            'rf_children', struct(), ...
            'rf_parents', struct(), ...
            'rf_links', struct() ...
        );
        status = struct( ...
            'loaded', struct() , ...
            'changed', struct() );
    end %properties
   
    % methods defined here 
    methods
        % class constructor
        function obj = rfObj()
            % add listners for data and metadata, children and parents
            addlistener(obj,'type','PostSet',@rfObj.handlePropChanges);
            addlistener(obj,'uuid','PreSet',@rfObj.handlePropChanges);
            addlistener(obj,'uuid','PostSet',@rfObj.handlePropChanges);
            addlistener(obj,'vuuid','PostSet',@rfObj.handlePropChanges);
            addlistener(obj,'created','PostSet',@rfObj.handlePropChanges);
            addlistener(obj,'modified','PostSet',@rfObj.handlePropChanges);
            %addlistener(obj,'file','PostSet',@rfObj.handlePropChanges);
            %addlistener(obj,'data','PostSet',@rfObj.handlePropChanges);
            %addlistener(obj,'metadata','PostSet',@rfObj.handlePropChanges);
            %addlistener(obj,'children','PostSet',@rfObj.handlePropChanges);
            %addlistener(obj,'parents','PostSet',@rfObj.handlePropChanges);
            %addlistener(obj,'def','PostSet',@rfObj.handlePropChanges);
            % set properties that cannot be set above
            % not sure why
            obj.def.rf_files.rf_base = '';
            obj.def.rf_files.rf_data = '';
            obj.def.rf_files.rf_metadata = '';
            obj.def.rf_data.rf_fields = {};
            obj.def.rf_children.rf_fields = {};
            obj.def.rf_children.rf_types = {};
            obj.def.rf_links.rf_fields = {};
            obj.def.rf_links.rf_types = {};
            obj.def.rf_links.rf_directions = {};
            obj.status.loaded.data = struct();
            obj.status.changed.data = struct();
            obj.status.changed.metadata = 0;
            obj.status.changed.type = 0;
            obj.status.changed.uuid = 0;
            obj.status.p_uuids = {};
            % set creation
            obj.created = datestr(now,'yyyy-mm-dd HH:MM:SS');
        end %function
    end % methods

    % methods defined in other files
    methods
        res = subsref(obj,S);
        varargout = subsasgn(obj,S,V);
        res = save(obj);
        disp(obj,type);
        setDataInfo(obj,field, value);
        res = setFiles(obj,indata);
        res = getFiles(obj,filtered);
        res = getDataFileName(obj,filtered);
        res = getMetadataFileName(obj,filtered);
        res = getDFN(obj,filtered);
        res = getMFN(obj,filtered);
      
    end %methods

    % static methods defined here
    methods (Static)
        function handlePropChanges(src,evnt)
            % check if we just changed value on one of the main properties
            switch evnt.EventName
                case 'PostSet'
                    % gets the object 
                    obj = evnt.AffectedObject;
                    % set changed in object status
                    obj.status.changed.(src.Name) = 1;
                    % based on which property has been changed
                    % we need to update the definition
                    switch (src.Name)
                        case 'type'
                            obj.def.rf_type = obj.type;
                        case 'uuid'
                            obj.def.rf_uuid = obj.uuid;
                            % remove the current entry from past uuids
                            obj.status.p_uuids(strcmp(obj.status.p_uuids,obj.uuid)) = [];
                        case 'vuuid'
                            obj.def.rf_vuuid = obj.vuuid;
                        case 'created'
                            obj.def.rf_created = obj.created;
                        case 'modified'
                            obj.def.rf_modified = obj.modified;
                        %case 'file'
                        %    obj.def.rf_file = obj.file;
                        case 'data'
                            % nothing to do
                        case 'metadata'
                        case 'children'
                        case 'parents'
                    end %switch
                case 'PreSet'
                    % gets the object
                    obj = evnt.AffectedObject;
                    % select the properties that is going to be changed
                    switch (src.Name)
                        case 'uuid'
                            % we need to verify that the old uuid is not
                            % in the list yet
                            if ~isempty(obj.uuid) && ~any(strcmp(obj.status.p_uuids,obj.uuid))
                                % we need to insert the new id
                                obj.status.p_uuids{end+1} = obj.uuid;
                            end %if
    
                    end %switch
            end %switch
        end %function
    end %methods
    
    % static methods defined in external files
    methods (Static)

        % load data into an object
        obj = load(indata)
        % unload/remove object from memory
        res = unload(indata)
        
        % load object info from file
        res = fileLoadInfo(file)
        % return info from "whos" command on inpput
        outdata = propInfo(indata)

    end %methods
end % classdef
