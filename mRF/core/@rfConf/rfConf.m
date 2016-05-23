classdef rfConf < handle
   
    properties
        % configuration file 
        % it can be xml, json or legacy
        fileName = 'rf.conf';

        
        % type of configuration file
        % matches the type of configuration file type:
        % xml, json or legacy
        fileType = 'unkown';
        
        % data read from configuration file
        fileData;
        
        % configuration data structure
        confData;
        
        % temporary structure used when building configuration structure
        temp;
        
        % configuration selected
        selection = 0;
        
        % automation
        automation = 'none';
        automationList = {'none', 'load', 'extract', 'select', 'start'};
        
        % menu type
        menuType = 'auto';
        menuTypeList = {'text', 'gui', 'auto'};
        
        % list of paths addedd when started database
        listPaths = {};
    end
    
    properties (Dependent, Hidden)
        % return file name
        file;
        
        % return file type
        type;
    end
    
    methods (Access = private)
        % constructor
        % we keep it private, so we can implement a singleton
        function obj = rfConf(conf)
            % 
            % create rfConf object
            %
            % if a file is provided, it tries to load the file and extract
            % configuration
            %
            % check if we have some configuration
            if nargin > 0 
                % check if conf is a string
                if isa(conf,'char')
                    % if conf is a string, we assume that is the file name
                    % containing the configuration

                    % check if user would like to automaticallyt search for conf file
                    if strcmp(tolower(conf),'auto') || ...
                      strcmp(tolower(conf),'<auto>')
                        % user folder
                        uhf = getuserdir();
                        % possible path to local configuration file
                        lcp = { ...
                          fullfile(uhf,'.RNEL'), ...
                          fullfile(uhf,'RNEL'), ...
                          fullfile(uhf,'MATLAB'), ...
                          fullfile(uhf,'Documents','MATLAB'), ...
                        };
                        % check if at least one path contains a configuration file
                        for i = 1:length(lcp)
                            % possible configuration file names
                            lcf = { ...
                              fullfile(lcp{i},'rf.json.conf'), ...
                              fullfile(lcp{i},'rf.xml.conf'), ...
                            };
                            for j = 1:length(lcf)
                                if exist(lcf{i})
                                    % local configuration file exists
                                    % use this one
                                    obj.ConfigurationFile = lcf{i};
                                    break;
                                end %if
                            end %for
                        end %for
                    else
                        % we assume that user passed a file path name
                        % save file
                        obj.fileName = conf;
                    end %if
                else
                    if isa(conf,'struct')
                        % if conf is a struct, we should have the following structure
                        % conf.fileName     = name of the file containing the configuration
                        % conf.automation   = here we specify if we want to load,
                        %                     extract, select and start rneldb. Actions are
                        %                     incrementals following the progression
                        %                      1) load
                        %                      2) extract
                        %                      3) select
                        %                      4) start
                        % conf.menuType     = which type of menu: text, GUI or auto
                        % conf.selection    = indicate the configuration
                        %                     that we want to select automatically. It is
                        %                     useful when automating tasks
    
                        if ( isfield(conf,'fileName') )
                            % save filename
                            obj.fileName = conf.fileName;
                        end
    
                        % check if we got automation in input and if it has
                        % a valid value
                        if ( isfield(conf,'automation') && ...
                                ~isempty(find(cellfun(@(s)any(strcmp(s,conf.automation)),obj.automationList))) )
                            % save automation settings
                            obj.automation = conf.automation;
                        end
    
                        % check if we have menutype in input and if it has
                        % a valid value
                        if ( isfield(conf,'menuType') && ...
                                ~isempty(find(cellfun(@(s)any(strcmp(s,conf.menuType)),obj.menuTypeList))) )
                            % save menu type
                            obj.menuType = conf.menuType;
                        end
                        
                        % check if we have a selection in input and if it
                        % has a valid value
                        if ( isfield(conf,'selection') && ...
                                isnumeric(conf.selection) )
                            % save menu type
                            obj.selection = conf.selection;
                        end
    
    
                        % automate actions
                        step = find(cellfun(@(s)any(strcmp(s,obj.automation)),obj.automationList));
                        if ( step > 1 )
                            % load file
                            obj.load();
                            if ( step > 2 ) 
                                % extact configuration from file
                                obj.extract();
                                if ( step > 3 ) 
                                    % select configuration
                                    obj.select();
                                    if ( step > 4 ) 
                                        % start database
                                        obj.start();
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    methods (Static)
        % static method in order to implement a singleton
        function obj = getInstance(varargin)
            % obj = rfConf::getInstance(conf)
            %
            % Static class method implementing the singleton
            %
            % If called without any arguments, it returns the class instance
            % if exists or null if it does not.
            %
            % When called with an argument, it returns the class instance
            % if already exists, otherwise it creates a new instance based
            % on the arguments passed.
            %
            % Input:
            %   conf: configuration parameters. Can be two different format
            %         1) (string): it contains the file name where the configuration is saved.
            %                      The file can be in xml or json format or the legacy format as the userInfo file
            %
            %         2) (struct): the struct contains the configuration
            %                      file name and also additional parameters to configure
            %                      which type of menu the user would like to have, if a
            %                      selection as to be made automatically or if the
            %                      databse has to be started automatically
            %         
            %                      struct structure:
            %
            %                      - conf.fileName     = name of the file containing the configuration
            %                      - conf.automation   = here we specify if we want to load,
            %                                            extract, select and start rneldb automatically. 
            %                                            Actions are incrementals following the progression:
            %                                            1) load
            %                                            2) extract
            %                                            3) select
            %                                            4) start
            %                      - conf.menuType     = which type of menu: text, GUI or auto
            %                      - conf.selection    = indicate the configuration that we want to select automatically. 
            %                                            It is useful when automating tasks
            %
            % Output
            %   obj: the singleton instance

            % 
            % persistent variable holding the reference to the singleton instance
            persistent uniqueInstance;
            
            % check if the singleton is already instantiated or not
            if isempty(uniqueInstance) && nargin > 0
                conf = varargin{1};
                % singleton needs to be instantiated
                obj = rfConf(conf);
                % save it in persistent variable
                uniqueInstance = obj;
            else
                % returned singleton object
                obj = uniqueInstance;
            end
            mlock;
        end
        
        % return if there is an active rneldbconf class instantiated
        function res = active()
            % res = rfConf::active()
            %
            % Static class method that return TRUE if the class
            % instantiated or not. FALSE otherwise
            %
            
            % get the instance from function getInstance and check if it is empty
            res = ~isempty(rfConf.getInstance());
        end
        
        % return the Constants for the selected configuration
        % if signleton is instantiated
        function C = sGetC()
            % C = rfConf::sGetC()
            %
            % Static class method that return TRUE if the class
            % instantiated or not. FALSE otherwise
            %
            
            % initialize output
            C = struct;
            % get singleton instance
            obj = rfConf.getInstance();
            % check if it is a valid class
            if ( ~isempty(obj) )
                % get current configuration
                C = obj.getC();
            end
        end
    end
    
    methods           
        % get function for file name
        function file = get.file(obj)
            % rneldDbConf get method for property file
            %
            % return configuration file name used in the singleton instance
            % the file name is stored in the property fileName
            %
            % Output
            %   file = configuration file name
            file = obj.fileName;
        end
        
        % get function for file type
        function type = get.type(obj)
            % rneldDbConf get method for property type
            %
            % return type of configuration file used in the singleton instance
            % the file type is stored in the property fileType
            %
            % Output
            %   type = configuration file type
            %          Options: xml, json, legacy, unknown
            %
            type = obj.fileType;
        end
        
        % set file name
        function obj = set.fileName(obj,fileName)
            % rneldDbConf set method for property fileName
            %
            % Set file name with new value and initialize object properties
            %
            % Output
            %   obj: this object
            %
            
            % save file name
            obj.fileName = fileName;
            % initialize the other variables
            obj.fileType = '';
            obj.fileData = '';
            obj.confData = struct;            
        end
        
        % get file name
        function fileName = get.fileName(obj)
            % rneldDbConf get method for property fileName
            %
            % return configuration file name used in the singleton instance
            %
            % Output
            %   type = configuration file name
            %
            fileName = obj.fileName;
        end
        
        % get file type
        function fileType = get.fileType(obj)
            % rneldDbConf get method for property type
            %
            % return type of configuration file used in the singleton instance
            %
            % Output
            %   type = configuration file type
            %          Options: xml, json, legacy, unknown
            %
            fileType = obj.fileType;
        end
                
        % load configuration data from file
        load(obj);
        
        % extract configuration structure from loaded data
        extract(obj);
        
        % select which configuration to use
        % if no selection is given, it will present a menu at console
        select(obj,selection);

        % if name is provided, it return data for that specific configuration,
        % otherwise returns current selected configuration if any
        C = getConf(obj,selection);
        
        % returns just the constants tree of the selected configuration
        % if a selection name is provided, it will return that
        % configuration
        C = getC(obj,selection);
        
        % get all data
        D = getData(obj);
        
        % get list of the name of all the configurations available
        [L, varargout] = getList(obj);
        
        % get current selection
        [n, varargout] = getSelection(obj);
        
        % start database with selcted configuration
        start(obj);
        
    end
    
    methods (Access = private)
        % set function for file
        function test = fileExists(obj,file)
            % check if the file exists
            if ~exist(file,'file')
                % file not found
                % print error and exit
                disp(['Configuration file', file, ' not found. Will no be able to start RNEL db']);
                error('rfConf:fileExists:1');
                test = false;
            end
            test = true
        end
        
        % load xml conf file
        loadXml(obj);
            
        % load json conf file
        loadJson(obj);
        
        % load legacy conf file
        loadLegacy(obj);
                
        % extract data from xml tree
        % top level function
        extractXml(obj);
        % recusrsive function
        S = extractXmlHelper(obj,items)
        % get attributes from xml tag
        A = getXmlAttributes(obj,item)
        
        % extract data from json string
        extractJson(obj);
        % recursive function to extract json elements
        [D J] = parseJsonValue(obj,json);
        % extract array from json string
        [A J] = parseJsonArray(obj,J)
        % extract object from json string
        [D J] = parseJsonObject(obj,J)
        % extract name/value pair from json string
        [N V J] = parseJsonNameValue(obj, J)
        % extract string from json string
        [S J] = parseJsonString(obj, J)
        % extract numeric value from json string
        [N J] = parseJsonNumber(obj, J)
        
        % extract data fromlegacy configuration
        extractLegacy(obj);
        
        % local import toolbox
        importToolbox(obj,toolbox_folder_name,dir_ignore);
        
    end
    
end
