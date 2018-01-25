classdef mdfObj < handle
    %
    % class: mdfObj
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
        mdf_def = struct( ...
            'mdf_type', '', ...
            'mdf_uuid', '', ...
            'mdf_vuuid', '', ...
            'mdf_created', '', ...
            'mdf_modified', '', ...
            'mdf_files', struct(), ...
            'mdf_data', struct(), ...
            'mdf_metadata', struct(), ...
            'mdf_children', struct(), ...
            'mdf_parents', struct(), ...
            'mdf_links', struct() ...
        );
        status = struct( ...
            'loaded', struct() , ...
            'changed', struct() );
    end %properties
   
    % methods defined here 
    methods
        % class constructor
        function obj = mdfObj(argin1,argin2)
                        
            % add listners for data and metadata, children and parents
            addlistener(obj,'type','PostSet',@mdfObj.handlePropChanges);
            addlistener(obj,'uuid','PreSet',@mdfObj.handlePropChanges);
            addlistener(obj,'uuid','PostSet',@mdfObj.handlePropChanges);
            addlistener(obj,'vuuid','PostSet',@mdfObj.handlePropChanges);
            addlistener(obj,'created','PostSet',@mdfObj.handlePropChanges);
            addlistener(obj,'modified','PostSet',@mdfObj.handlePropChanges);
            %addlistener(obj,'file','PostSet',@mdfObj.handlePropChanges);
            %addlistener(obj,'data','PostSet',@mdfObj.handlePropChanges);
            %addlistener(obj,'metadata','PostSet',@mdfObj.handlePropChanges);
            %addlistener(obj,'children','PostSet',@mdfObj.handlePropChanges);
            %addlistener(obj,'parents','PostSet',@mdfObj.handlePropChanges);
            %addlistener(obj,'def','PostSet',@mdfObj.handlePropChanges);
            % set properties that cannot be set above
            % not sure why
            obj.mdf_def.mdf_files.mdf_base = '';
            obj.mdf_def.mdf_files.mdf_data = '';
            obj.mdf_def.mdf_files.mdf_metadata = '';
            obj.mdf_def.mdf_data.mdf_fields = {};
            obj.mdf_def.mdf_children.mdf_fields = {};
            obj.mdf_def.mdf_children.mdf_types = {};
            obj.mdf_def.mdf_links.mdf_fields = {};
            obj.mdf_def.mdf_links.mdf_types = {};
            obj.mdf_def.mdf_links.mdf_directions = {};
            obj.status.loaded.data = struct();
            obj.status.changed.data = struct();
            obj.status.changed.metadata = 0;
            obj.status.changed.type = 0;
            obj.status.changed.uuid = 0;
            obj.status.p_uuids = {};
            
            % process input arguments
            if nargin > 0
                % we got some input
                if ischar(argin1)
                	% we assume that we got 
                    obj.type = argin1;
                    if nargin > 1
                        % we got the uuid from the user
                        obj.uuid = argin2;
                    else
                        obj.uuid = mdf.UUID();
                    end %if
                    
                elseif isstruct(argin1)
                    if isfield(argin1,'type')
                        obj.type = argin1.type;
                    else
                        obj.type = 'Standard';
                    end %if
                    if isfield(argin1,'uuid')
                        obj.uuid = argin.uuid;
                    else
                        obj.uuid = mdf.UUID();
                    end %if
                else
                    % nothing to do
                    % do not set anything
                    % we leave the object empty
                end %if
            else
                % no input arguments
                obj.type = 'Standard';
                obj.uuid = mdf.UUID();
            end %if

            
            % set creation
            obj.created = datestr(now,'yyyy-mm-dd HH:MM:SS');
        end %function
    end % methods

    % methods defined in other files
    methods
        res = subsref(obj,S);
        varargout = subsasgn(obj,S,V);
        res = save(obj,timing);
        disp(obj,type);
        setDataInfo(obj,field, value);
        res = setFiles(obj,indata,reset);
        res = getFiles(obj,filtered);
        res = getDataFileName(obj,filtered);
        res = getMetadataFileName(obj,filtered);
        res = getDFN(obj,filtered);
        res = getMFN(obj,filtered);
        res = remove(obj);
        res = getSize(obj,details);   
        res = size(obj);
        outdata = getUuids(obj,group,property,format);
        len = getLen(obj,property,type);
        res = listDataProperties(obj);
        res = ldp(obj);
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
                            obj.mdf_def.mdf_type = obj.type;
                        case 'uuid'
                            obj.mdf_def.mdf_uuid = obj.uuid;
                            % remove the current entry from past uuids
                            obj.status.p_uuids(strcmp(obj.status.p_uuids,obj.uuid)) = [];
                        case 'vuuid'
                            obj.mdf_def.mdf_vuuid = obj.vuuid;
                        case 'created'
                            obj.mdf_def.mdf_created = obj.created;
                        case 'modified'
                            obj.mdf_def.mdf_modified = obj.modified;
                        %case 'file'
                        %    obj.mdf_def.mdf_file = obj.file;
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
