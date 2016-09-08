classdef mdfCrawler < handle
   
    properties
        % start object
        sobj = [];
        
        % object list
        objList = struct();
        
        % relation list
        relList = struct();
    end
        
    methods (Access = private)
        % constructor
        % we keep it private, so we can implement a singleton
        function obj = mdfCrawler()
            % 
            % create mdfCrawler object
            %
            % if a file is provided, it tries to load the file and extract
            % configuration
            %
        end % function
            
    end %methods
    
    methods (Static)
        % static method in order to implement a singleton
        function obj = getInstance(varargin)
            % obj = mdfCrawler::getInstance(conf)
            %
            % Static class method implementing the singleton
            %
            % Output
            %   obj: the singleton instance

            % 
            % persistent variable holding the reference to the singleton instance
            persistent uniqueInstance;
            
            % check if the singleton is already instantiated or not
            if isempty(uniqueInstance)
                % singleton needs to be instantiated
                obj = mdfCrawler();
                % save it in persistent variable
                uniqueInstance = obj;
            else
                % returned singleton object
                obj = uniqueInstance;
            end %if
            mlock;
        end %function
    end %methods
    
    methods (Static)
        % static methods defined in other files
        [relL,objL] = getRelations(startObj);
        res = json(startObj,relFile,objFile);
        
    end %methods
    
    methods
        % methods defined in thoer files
        res = crawler(obj,startObj);
        
    end %methods
    
end %classdef 