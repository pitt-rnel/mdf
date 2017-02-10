classdef (Sealed) mdf < handle

    properties (Constant)
        libraries = '../../libs';
        pattern = '/[@\w]+/\.\./';
    end %properties

    methods (Static)
        % all static methods defined here

        function singleObj = getInstance()
            % function singleObj = mdf.getInstance()
            %
            % return singleton instance of mdf class

            % lock function in memory
            mlock;
            % use a persistent variable to mantain the instance
            persistent localObj
            % check if the persisten object is actually an object and is
            % valid
            if isempty(localObj) || ~isvalid(localObj)
                % instantiate new object
                localObj = mdf;
            end %if
            % return object
            singleObj = localObj;
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
            else nargin > 1
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
            LoadLibYaml();
            
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
            % check if we have mdf data base
            if ( ~isfield(C,'DATA_BASE') || ...
                    ~exist(C.DATA_BASE,'dir') )
                % we cannot proceed
                throw(MException('mdfConf:start',...
                    '3: Configuration missing MDF data folder!!!'));
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
            odb = mdfDB.getInstance();
            % memory manage objects
            om = mdfManage.getInstance();
           
            % prepare output
            res = struct( ...
                'mdf', omdf, ...
                'conf', oconf, ...
                'db', odb, ...
                'manage', om);
        end %function
    end %methods

    % static methods defined in external files
    methods (Static)
        % add parent child relationship
        res = addParentChildRelation(parent,child,prop);
        res = apcr(parent,child,prop);
        % remove parent child relationship
        res = rmParentChildRelation(parent,child,prop);
        res = rpcr(parent,child,prop);
        % add links
        res = addUnidirectionalLink(source,dest,sProp);
        res = aul(source,dest,sProp);
        res = addBidirectionalLink(source,dest,sProp,dProp);
        res = abl(source,dest,sProp,dProp);
        % rm links
        res = rmUnidirectionalLink(source,dest,sProp);
        res = rul(source,dest,sProp);
        res = rmBidirectionalLink(source,dest,sProp,dProp);
        res = rbl(source,dest,sProp,dProp);
        % generate uuid 
        uuid = UUID();
        % unload/remove object from memory
        res = unload(indata);
        % load object in memory
        outdata = load(indata);
        % convert cell to struct
        outdata = c2s(indata);
        % given uuid or object, returns both
        [uuid, object] = getUuidAndObject(indata);
        [uuid, object] = getUAO(indata);
        % memory usage
        [total,used,free] = memoryUsage();
        [total,used,free] = mu();
    end %methods
end %function
