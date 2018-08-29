classdef (Sealed) mdfDB < handle

    properties (Constant)
        Jar =  '../../../java/mongo-java-driver-3.8.0.jar';
        SchemaFunctionFile = '../../../javascript/mdfDbSchema.js';
        DEFAULT_HOST = 'localhost';
        DEFAULT_PORT = 27017;
        DEFAULT_DATABASE = 'mdf';
        DEFAULT_COLLECTION = 'mdf';
    end  

    properties
        % connection info
        host = '';
        port = [];
        database = [];
        collection = [];
        % connection objects
        m = [];
        db = [];
        coll = [];
        % variables used in checking configuration
        fieldsRequired = {};
        fieldInfo = struct();
        % variable containing the javascript code to get the collection
        % schema
        jsSchemaFunction = '';
    end

    methods (Access = private)
        function obj = mdfDB
            % list of field types
            obj.fieldInfo = struct( ...
                'host', struct( ...
                    'required', 1, ...
                    'type', 'char'), ...
                'port', struct( ...
                    'required', 1, ...
                    'type', 'numeric'), ...
                'database', struct( ...
                    'required', 1, ...
                    'type', 'char'), ...
                'collection', struct( ...
                    'required', 1, ...
                    'type', 'char'), ...
                'connect', struct( ...
                    'required', 0, ...
                    'type', 'boolean') ...
            );
            % list of required fields
            t1 = boolean(cell2mat(cellfun(@(f) obj.fieldInfo.(f).required, fields(obj.fieldInfo),'UniformOutput',0)));
            t2 = fields(obj.fieldInfo);
            obj.fieldsRequired = t2{t1};
        end
    end
    methods (Static)
        function obj = getInstance(varargin)
            % access the global variable containing reference to the main
            % mdf core objects
            global omdfc;
            % check if it exists, otherwise initialize it
            if ~isstruct(omdfc)
                omdfc = struct();
            end %if
            % check if the field for db exists
            if ~isfield(omdfc,'db')
                omdfc.db  = [];
            end %if

            release = false;
            if nargin > 0 && isa(varargin{1},'char') && strcmp('release',lower(varargin{1}))
                release = true;
            end %if
            
            conf = '';
            if nargin == 1 && isstruct(varargin{1})
                conf = varargin{1};
            elseif nargin >= 4
                conf = struct( ...
                    'host', varargin{1}, ...
                    'port', varargin{2}, ...
                    'database', varargin{3}, ...
                    'collection', varargin{4}, ...
                    'connect',  false ...
                );
                if nargin > 4
                    conf.connect = varargin{5};
                end %if
            end %if
            %
            % check if connect is defined
            if isstruct(conf) && ~isfield(conf,'connect')
                conf.connect = false;
            end %if

            % check if we need to release the current singleton
            if release
                % we need to clear the current unique instance 
                % (aka singleton)
                if isa(omdfc.db,'mdfDB')
                    % delete isntance
                    delete(omdfc.db);
                    omdfc.db = [];
                    % we are done
                    return
                end %if
            % check if the singleton is already instantiated or not
            elseif ( isempty(omdfc.db) || ~isa(omdfc.db,'mdfDB') )
                % singleton needs to be instantiated
                obj = mdfDB();
                % save it in persistent variable
                omdfc.db = obj;
            else
                % returned singleton object
                obj = omdfc.db;
            end %if
            
            % if conf has been given, make sure to memorize it
            if isstruct(conf) && ~isempty(conf)
                if obj.isValidConf(conf)
                    obj.setDbUri(conf);
                end %if
                % connect to database
                if conf.connect
                    obj.connect(conf);
                end %if
            end %if
            
            % load the javascript code to get the collection schema
            fid = fopen(obj.SchemaFunctionFile);
            obj.jsSchemaFunction = strrep(char(fread(fid,inf)'),'<COLLECTION>',obj.collection);
            fclose(fid);
        end %function
    end

    methods
        res = connect(obj,conf)
        res = isValidCollection(obj)
        res = isValidConnection(obj)
        res = isValidDatabase(obj)
        res = isValid(obj)
        res = isValidConf(obj,conf)
        res = isConfSet(obj);
        res = find(obj,query,projection,sort)
        %res = delete(obj,query)
        res = insert(obj,query)
        res = insertMany(obj,query)        
        res = update(obj,query,values,upsert)
        res = getCollStats(obj,varargin)
        res = aggregate(obj,pipeline)
        res = mapReduce(obj,map,reduce,options)
        
        outobj = toBasicDBObject(obj,inobj)
        outobj = toBsonDocument(obj,inobj)
        
        [res, ed] = validateRelationships(obj)
        [res, ed] = validateUuids(obj)
        [res, stats, res] = validateSchema(obj)
    end
    
    methods (Static)
        output = prepQuery(input)
    end %methods static
end

