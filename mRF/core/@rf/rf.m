classdef (Sealed) rf < handle

    properties (Constant)
        libraries = '../../libs';
        pattern = '/[@\w]+/\.\./';
    end %properties

    methods (Static)
        % all static methods defined here

        function singleObj = getInstance()
            % function singleObj = rf.getInstance()
            %
            % return singleton instance of rf class

            % lock function in memory
            mlock;
            % use a persistent variable to mantain the instance
            persistent localObj
            % check if the persisten object is actually an object and is
            % valid
            if isempty(localObj) || ~isvalid(localObj)
                % instantiate new object
                localObj = rf;
            end %if
            % return object
            singleObj = localObj;
        end %function

        function res = init()
            % function obj = rf.init()
            %
            % initialize the environment for rf system to run
            % includes loading all the libraries
            %
            
            res = 1;
            
            % get singleton
            obj = rf.getInstance();
            
            % get current folder
            [cf,~,~] = fileparts(mfilename('fullpath'));
            % define libraries folder
            lf = fullfile(cf,obj.libraries);
            % removes double dots if needed
            tmp1 = lf;
            tmp2 = regexprep(tmp1,obj.pattern,'/');
            while strcmp(tmp1,tmp2)==0
                tmp1 = tmp2;
                tmp2 = regexprep(tmp1,obj.pattern,'/');
            end %while
            lf = tmp2;
            
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
            
            % instantiate database and memory manage objects
            odb = rfDB.getInstance();
            om = rfManage.getInstance();
           
        end %function
    end %methods

    % stati methods defined in external files
    methods (Static)
        % add parent child relationship
        res = addParentChildRelation(parent,child,prop);
        res = apcr(parent,child,prop);
        % remove parent child relationship
        res = rmParentChildRelation(parent,child,prop);
        res = rpcr(parent,child,prop);
        % generate uuid 
        uuid = UUID();
        % unload/remove object from memory
        res = unload(indata);
        % load object in memory
        outdata = load(indata);
        
    end %methods
end %function
