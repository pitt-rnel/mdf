classdef (Sealed) mdfManage < handle

    properties
        object = [];
        uuid = {};
        file = {};
    end

    methods (Access = private)
        function obj = mdfManage()
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
            if ~isfield(omdfc,'manage')
                omdfc.manage  = [];
            end %if

            release = false;
            if nargin > 0 && isa(varargin{1},'char') && strcmp('release',lower(varargin{1}))
                release = true;
            end %if

            % check if we need to release the current singleton
            if release
                % we need to clear the current unique instance 
                % (aka singleton)
                if isa(omdfc.manage,'mdfManage')
                    % delete isntance
                    delete(omdfc.manage);
                    omdfc.manage = [];
                    % we are done
                    return
                end %if
            % check if the singleton is already instantiated or not
            elseif ( isempty(omdfc.manage) || ~isa(omdfc.manage,'mdfManage') )
                % singleton needs to be instantiated
                obj = mdfManage();
                % save it in persistent variable
                omdfc.manage = obj;
            else
                % returned singleton object
                obj = omdfc.manage;
            end %if

        end
    end

   methods 
      function res = index(obj,query)
          % initialize output
          res = [];
          % check if input is a struct or a string
          switch class(query)
              case {'mdfObj'}
                  res = obj.indexByUuid(query.uuid);
              case {'struct'}
                  % check if we need to search by uuid or by file
                  if isfield(query,'uuid')
                      % search by uuid
                      res = obj.indexByUuid(query.uuid);
                  elseif isfield(query,'file')
                      % search by file
                      res = obj.indexByFile(query.file);
                  end %if
              case {'char'}
                  % check first by uuid and than by file name 
                  res = obj.indexByUuid(query);
                  if isempty(res)
                      res = obj.indexByFile(query);
                  end %if
              otherwise
                  throw( ...
                      MException( ...
                        'mdfManage:index' ,...
                        'input class not recognized'));
          end %switch
      end
      
      function res = indexByUuid(obj, uuid)
          % function res = obj.existByUuid(uuid)
          %
          % returns true if the object with uuid exists
          % in memory (aka has already been loaded
          %

          res = find(cellfun(@(x) strcmp(x,uuid),obj.uuid),1,'first');
      end %function
      
      function res = indexByFile(obj, file)
          % function res = obj.existByFile(file)
          %
          % returns true if the object loaded from file exists
          % in memory (aka has already been loaded)
          %

          res = find(cellfun(@(x) strcmp(x,file),obj.file),1,'first');
      end %function

      function res = exist(obj,query)
          res =any(obj.index(query));
      end %function

      function res = existByUuid(obj,uuid)
          res = any(obj.indexByUuid(uuid));
      end %function

      function res = existByFile(obj,file)
          res = any(obj.indexByFile(file));
      end %function

      function res = get(obj,query)
          % find the index of the object required
          index = obj.index(query);
          % initialize output
          res = [];
          % retrieve object if it was found
          if ~isempty(index)
              % object found (aka index is not empty)
              res = obj.object(index(1));
          end %if 
      end %function

      function res = insert(obj,uuid,file,object)
          % check if the object is already present in memory
          res = obj.index(uuid);
          % proceed with insert only if object was not found
          if isempty(res)
              % insert object at the end of the memory arrays
              % position
              pos = length(obj.object) + 1;
              % insert object
              if pos == 1
                  obj.object = object;
              else
                  obj.object(pos) = object;
              end %if
              % insert uuid
              obj.uuid{pos} = uuid;
              % insert file
              obj.file{pos} = file;
              % return position
              res = pos;
          end %if 
      end

      function res = removeByIndex(obj, index)
          % function res = obj.removeByIndex(index)
          %
          % remove the object at index passed from the set/queue 
          % of objects that are managed by this class (aka mdf memory management)
          % NB: this is mostly a private method.
          %
          % input:
          % - index: (integer) index in the internal queue of the object to be removed
          %
          % output:
          % - res: (boolean) true if object has been removed
          %
          % initialize output
          res = false;
          % remove object if it was found
          if ~isempty(index)   
              % object found, removed from memory arrays
              obj.object(index) = [];
              obj.uuid(index) = [];
              obj.file(index) = [];
              res = true;
          end %if 
      end %function
      
      function res = remove(obj, query)
          % function res = obj.remove(query)
          %
          % remove object from the memory management
          % IMPORTANT: it does not delete the object
          %
          % Input:
          % - query: mdfObj, object uuid, object file
          %
          % Output:
          % - res: true if successful, false if not
          %
          % find the index of the object required
          index = obj.index(query);
          % remove object if it was found
          res = false;
          if ~isempty(index)
              res = obj.removeByIndex(index(1));
          end %if
      end %function
      
      function res = clear(obj,query)
          % function res = obj.clear(query)
          %
          % unload objects from memory and memory management.
          % This routine delete the object from memory, 
          % afterward is not longer accessible.
          % to be able to access the cleared objects, they would need to be
          % reloaded.
          %
          % Input:
          % - query: mdfObj, object uuid, object file
          %          if an array of the above is passed in, 
          %          it will remove from memory all the objects in the array
          %          It can be an array of handles to mdfObj,
          %          or a cell array with a mix of the three items
          %          specified above
          %
          % Output:
          % - res: number of object cleared
          %
          
          % initialize output
          res = 0;

          % check if we got a cell array
          if iscell(query)
              %
              % loop on all the items 
              indexes = cell2mat(cellfun(@(item) obj.index(item),query,'UniformOutput',0));

          elseif isa(query,'mdfObj') && length(query)>1
              %
              % loop on all the items
              indexes = arrayfun(@(item) obj.index(item),query);

          else

              indexes = obj.index(query);
          end %if

          % sort indexes
          indexes = sort(indexes);
     
          for i = length(indexes):-1:1
              % find the index of the object required
              index = indexes(i);
              % clear object from memory if it was found
              if ~isempty(index)
                  % object found, 
                  % remove object from matlab memory
                  mdfObj = obj.object(index(1));
                  delete(mdfObj);
                  % removed from memory arrays
                  res1 = obj.removeByIndex(index(1));
                  if res1
                      res = res + 1;
                  end %if
              end %if 
          end %if
      end %function
      
      function res = clearAll(obj)
          % function res = obj.clearAll(query)
          %
          % unload all objects from memory and memory management.
          % This routine delete the objects from memory, 
          % afterward they are no longer accessible
          %
          % Input:
          % - NONE
          %
          % Output:
          % - res: number of object cleared
          %
          % initialize output
          res = 0;
          % loop on all objects in memory
          for i = length(obj.object):-1:1
              % remove object from matlab memory
              mdfobj = obj.object(i);
              delete(mdfobj);
              % removed from memory arrays
              res1 = obj.removeByIndex(i);
              if res1
                  res = res + 1;
              end %if
          end %for
      end %function

      function res = usage(obj)
          % function res = obj.usage()
          %
          % returns the number of elements currently stored in memeory and managed by the class
          %
          % Input:
          % - NONE
          % 
          % Output:
          % - res: (integer) number of element in memory
          %
   
          res = length(obj.object);
      end %function
   end
end
