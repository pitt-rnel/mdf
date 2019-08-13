classdef (Sealed) mdf < handle

    properties (Constant)
        libraries = '../../libs';
        pattern = '/[@\w]+/\.\./';
        version = '1.6';
    end %properties

    properties
        WHICH_JSON = 'NONE';
        VALIDATION = [];
    end %properties

    methods (Static)
        % all static methods defined here

        function obj = getInstance(varargin)
            % function singleObj = mdf.getInstance()
            %
            % return singleton instance of mdf class
            
            %
            % see if we got an input
            action = '';
            if nargin > 0
                action = varargin{1};
            end %if
            
            % 
            % we check if the global place maker for mdf exists and if it has a valid mdfConf in it
            global omdfc;
            if ~isstruct(omdfc)
                omdfc = struct();
            end %if

            if ~isfield(omdfc,'mdf')
                omdfc.mdf  = [];
            end %if

            % check if we need to release the current singleton
            if isa(action,'char') && strcmp('release',lower(action))
                % we need to clear the current unique instance 
                % (aka singleton)
                if isa(omdfc.mdf,'mdf')
                    % delete isntance
                    delete(omdfc.mdf);
                    omdfc.mdf = [];
                    % we are done
                    return
                end %if
            % check if the singleton is already instantiated or not
            elseif ( isempty(omdfc.mdf) || ~isa(omdfc.mdf,'mdf') )
                % singleton needs to be instantiated
                obj = mdf();
                % save it in persistent variable
                omdfc.mdf = obj;
            else
                % returned singleton object
                obj = omdfc.mdf;
            end %if

            % define run time constants
            obj.WHICH_JSON = mdf.whichJson();
            obj.VALIDATION = struct( ...
                'MDF_COLLECTION', struct( ...
                    'DATABASE', struct( ... 
                        'DATABASE' , 'MONGODB'  , ...
                        'MONGODB'  , 'MONGODB' ), ...
                    'DATA', struct( ...
                        'MAT_FILE' , 'MAT_FILE'  , ...
                        'MATFILE'  , 'MAT_FILE'  , ...
                        'FILE'     , 'MAT_FILE'  , ...
                        'MAT'      , 'MAT_FILE'  , ...
                        'M'        , 'MAT_FILE'  , ...
                        'MONGODB'  , 'MONGODB'   , ... 
                        'DATABASE' , 'MONGODB'   , ...
                        'DB'       , 'MONGODB'   , ...
                        'D'        , 'MONGODB'   , ...
                        'MONGODB_GRIDFS' , 'MONGODB_GRIDFS'  , ... 
                        'GRIDFS'         , 'MONGODB_GRIDFS'  , ...
                        'GFS'            , 'MONGODB_GRIDFS'  , ...
                        'G'              , 'MONGODB_GRIDFS' )), ...
                'MDF_COLLECTION_TYPE', struct( ...
                    'MAT_FILE' , 'MAT_FILE' , ...
                    'MIXED'    , 'MAT_FILE' , ...
                    'M'        , 'MAT_FILE' , ...
                    'V_1_4'    , 'MAT_FILE' , ...
                    'MONGODB'  , 'MONGODB' , ...
                    'DATABASE' , 'MONGODB' , ...
                    'DB'       , 'MONGODB' , ...
                    'V_1_5'    , 'MONGODB' , ...
                    'MONGODB_GRIDFS' , 'MONGODB_GRIDFS' , ...
                    'GRIDFS'         , 'MONGODB_GRIDFS' , ...
                    'GFS'            , 'MONGODB_GRIDFS' ) ...
             );

        end %function

        function res = init(varargin)
            % function obj = mdf.init(arg1...)
            %
            % initialize the environment for mdf system to run
            % includes loading all the libraries
            %
            % possible inputs
            % - (string) configuration file for mdfConf
            % - (numeric) active configuration to be selected
            % or
            % - (struct) structure with the following fields
            %   * confFile = configuration file for mdfConf
            %   * confSel = active configuration to be selected
            %
            
            % initialize output
            res = 0;
            
            % check input
            confFile = 'auto';
            confSel = [];
            if nargin == 1
                if ischar(varargin{1})
                    % if it is a string, we use it as file name of the
                    % configuration
                    confFile = varargin{1};
                elseif isnumeric(varargin{1})
                    confSel = varargin{1};
                    % if it is numeric, we use it as selection wanted
                elseif isstruct(varargin{1})
                    % if it is a struct, we assume that the user passed
                    % everything in a structure
                    if isfield(varargin{1},'confFile')
                        confFile = varargin{1}.confFile;
                    end %if
                    if isfield(varargin{1},'confSel')
                        confSel = varargin{1}.confSel;
                    end %if
                end %if
            elseif nargin > 1
                % we got 2 or more arguments
                % we assume that first one is the file namefor the
                % configuration file and the second is the configuration
                % selected
                confFile = varargin{1};
                confSel = varargin{2};
            end %if
            
            % get singleton
            omdf = mdf.getInstance();
            
            % get current folder
            [cf,~,~] = fileparts(mfilename('fullpath'));
            % define libraries folder
            lf = fullfile(cf,mdf.libraries);
            % removes double dots if needed
            % if we are on windows, makes sure to transform file separator
            % to unix like
            tmp1 = lf;
            if ispc
                tmp1 = regexprep(lf,'\\','/');
            end %if
            tmp2 = regexprep(tmp1,mdf.pattern,filesep);
            while strcmp(tmp1,tmp2)==0
                tmp1 = tmp2;
                tmp2 = regexprep(tmp1,mdf.pattern,filesep);
            end %while
            % takes into account winodws pathing
            if ispc
                lf = regexprep(tmp2,'/','\');
            else
                lf = tmp2;
            end %if
            
            % list everything in libraries
            list = dir(lf);
            % load all matlab libraries
            for i = 3:length(list)
                addpath(fullfile(lf,list(i).name));
            end %for

            % convert a test yaml string to load the java library
            %tmp1 = ParseYaml('action: "Loading java library"');
            % load yaml java library
	    % yaml java lib is loaded through static java path
            %LoadLibYaml();
            
            % instantiate configuration class
            oconf = mdfConf.getInstance( ...
                struct( ...
                    'fileName', confFile, ...
                    'automation', 1));
            % load configuration file
            oconf.load();
            % extract configuration info from configuration file content
            oconf.extract();
            % select the configuration
            oconf.select(confSel);
            % run statr function, in case there are some start function
            % configured
            oconf.start();

            % get complete configuration structure
            C = oconf.getC();
            % check if I have all the basic constants defined and if they
            % are valid
            %
            % check if we have mdf code base
            if ( ~isfield(C,'CODE_BASE') || ...
                    ~exist(C.CODE_BASE,'dir') )
                % we cannot proceed
                throw(MException('mdfConf:start',...
                    '1: Configuration missing MDF code folder!!!'));
            end %if
            % check if we have mdf core code base
            if ( ~isfield(C,'CORE_BASE') || ...
                    ~exist(C.CORE_BASE,'dir') )
                % we cannot proceed
                throw(MException('mdfConf:start',...
                    '2: Configuration missing MDF core code folder!!!'));
            end %if
            % check if we have the collection configuration
            if ( isfield(C,'MDF_COLLECTION') && ...
                isfield(C.MDF_COLLECTION,'DB') && ...
                isfield(C.MDF_COLLECTION,'YAML') && ...
                isfield(C.MDF_COLLECTION,'DATA') )
                % newer configuration
                % 
                % set the database type
                if isfield(omdf.VALIDATION.MDF_COLLECTION.DATABASE,C.MDF_COLLECTION.DB)
                   C.MDF_COLLECTION.DB = omdf.VALIDATION.MDF_COLLECTION.DATABASE;
                else
                   throw(MException('mdfConf:start',...
                       ['3: Invalid MDF collection database!!!']));
                end %if
                %
                % check yaml
                C.MDF_COLLECTION.YAML = ( C.MDF_COLLECTION.YAML == true );
                %
                %
                % set where to save the data
                if isfield(omdf.VALIDATION.MDF_COLLECTION.DATA,C.MDF_COLLECTION.DATA)
                   C.MDF_COLLECTION.DATA = omdf.VALIDATION.MDF_COLLECTION.DATA;
                else
                   throw(MException('mdfConf:start',...
                       ['4: Invalid MDF collection data!!!']));
                end %case

            elseif ( isfield(C,'MDF_COLLECTION_TYPE') )
                % <MDF_COLLECTION_TYPE>MIXED, M, V_1_4</MDF_COLLECTION_TYPE>
                % <MDF_COLLECTION_TYPE>DATABASE, DB, V_1_5</MDF_COLLECTION_TYPE>
                % check if type is correct and convert to standard format

                if isfield(omdf.VALIDATION.MDF_COLLECTION_TYPE,C.MDF_COLLECTION_TYPE)
                    C.MDF_COLLECTION_TYPE = omdf.VALIDATION.MDF_COLLECTION_TYPE;
                else
                    throw(MException('mdfConf:start',...
                        ['5: Invalid MDF collection type!!!']));
                        
                end %switch

            else
                % we cannot proceed
                throw(MException('mdfConf:start',...
                    ['6: Configuration missing MDF collection configuration!!!']));
            end %if


            % check if we have mdf data base if we operates in mixed mode (v1.4.x)
            if ( strcmp(C.MDF_COLLECTION_TYPE,'MAT_FILE') == 1 && ...
                ( ~isfield(C,'DATA_BASE') || ...
                  ~exist(C.DATA_BASE,'dir') ) )
                % we cannot proceed
                throw(MException('mdfConf:start',...
                    ['7: Configuration missing MDF data folder (' C.DATA_BASE ')!!!']));
            end %if

            % first of all needs to add functions root
            % so we can use the function addpath_recurse
            pathCell = regexp(path, pathsep, 'split');
            if ispc  
                % Windows is not case-sensitive
                onPath = any(strcmpi(C.CORE_BASE, pathCell));
            else
                onPath = any(strcmp(C.CORE_BASE, pathCell));
            end %if
            if ~onPath
                disp([' - adding core code path: ' C.CORE_BASE]);
                addpath(C.CORE_BASE);
                disp('...Done!!!');
            else
                disp('Core folder already in matlab path');
            end %if
        
            % instantiate database object
            odb = mdfDB.getInstance(true);
            % memory manage objects
            om = mdfManage.getInstance();
           
            % prepare output
            res = struct( ...
                'mdf', omdf, ...
                'conf', oconf, ...
                'db', odb, ...
                'manage', om);
        end %function

        function res = terminate()
            % function res = terminate()
            %
            % release and destroy all the core components of the mdf data collection
            %
            res = 0;
            
            % release all the memory
            % clear all the mdf objects
            om = mdfManage.getInstance();
            om.clearAll();
            
            % release all the classes
            mdfManage.getInstance('release');
            mdfDB.getInstance('release');
            mdfConf.getInstance('release');
            mdf.getInstance('release');
            
            res = 1;
        end % terminate

        function res = reinit(varargin)
            % function res=reinit(vargargin)
            %
            % close current data collection
            % and restart with a new one
            mdf.terminate();
            res = mdf.init(varargin{:});
        end
        
	function res = whichJson() {
            % function res = mdf.whichJson()
            %
            % returns which json library we should use
            % added for backward compatibility
            
            if (exist('jsondecode') == 5)
                res = 'MATLAB';
            else
                res = 'JSONLAB';
            end %if
        end %if

    end %methods

    % static methods defined in external files
    methods (Static)
        % add parent child relationship
        [res, outparent, outchild] = addParentChildRelation(inparent,inchild,prop);
        [res, outparent, outchild] = apcr(inparent,inchild,prop);
        % remove parent child relationship
        [res, outparent, outchild] = rmParentChildRelation(inparent,inchild,prop);
        [res, outparent, outchild] = rpcr(inparent,inchild,prop);
        % add links
        [res, outsource, outdest] = addUnidirectionalLink(insource,indest,sProp);
        [res, outsource, outdest] = aul(insource,indest,sProp);
        [res, outsource, outdest] = addBidirectionalLink(insource,indest,sProp,dProp);
        [res, outsource, outdest] = abl(insource,indest,sProp,dProp);
        % rm links
        [res, outsource, outdest] = rmUnidirectionalLink(insource,indest,sProp);
        [res, outsource, outdest] = rul(insource,indest,sProp);
        [res, outsource, outdest] = rmBidirectionalLink(insource,indest,sProp,dProp);
        [res, outsource, outdest] = rbl(insource,indest,sProp,dProp);
        % generate uuid 
        uuid = UUID();
        % unload/remove object from memory
        res = unload(indata);
        % load object in memory
        outdata = load(varargin);
        % convert cell to struct
        outdata = c2s(indata);
        % given uuid or object, returns both
        [uuid, object] = getUuidAndObject(indata);
        [uuid, object] = getUAO(indata);
        % memory usage
        [total,used,free] = memoryUsage();
        [total,used,free] = mu();
        % helper function
        [indata] = toJson(outdata);
        [indata] = fromJson(outdata);
    end %methods
end %function


