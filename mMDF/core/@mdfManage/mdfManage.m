classdef (Sealed) mdfManage < handle

   properties
      object = [];
      uuid = {};
      file = {};
   end

   methods (Access = private)
      function obj = mdfManage
      end
   end

   methods (Static)
      function singleObj = getInstance
          mlock;
          persistent localObj
          if isempty(localObj) || ~isvalid(localObj)
              localObj = mdfManage;
          end
          singleObj = localObj;
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
          res = obj.removeByIndex(index(1));
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
          % - res: true if successful, false if not
          %
          
          % check if we got a cell array
          if iscell(query)
              %
              % loop on all the items 
              res = cell2mat(cellfun(@(item) obj.clear(item),query,'UniformOutput',0));
              return
          elseif isa(query,'mdfObj') && length(query)>1
              %
              % loop on all the items
              res = arrayfun(@(item) obj.clear(item),query);
              return
          end %if

          % find the index of the object required
          index = obj.index(query);
          % initialize output
          res = false;
          % clear object from memory if it was found
          if ~isempty(index)
              % object found, 
              % remove object from matlab memory
              mdfObj = obj.object(index(1));
              delete(mdfObj);
              % removed from memory arrays
              res = obj.removeByIndex(index(1));
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
          % - res: true if successful, false if not
          %
          % initialize output
          res = false;
          % loop on all objects in memory
          for i = length(obj.object):-1:1
              % remove object from matlab memory
              mdfobj = obj.object(i);
              delete(mdfobj);
              % removed from memory arrays
              res = obj.removeByIndex(i);
          end %for
      end %function
   end
end
