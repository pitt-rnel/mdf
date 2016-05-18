classdef (Sealed) rfManage < handle

   properties
      object = [];
      uuid = {};
      file = {};
   end

   methods (Access = private)
      function obj = rfManage
      end
   end

   methods (Static)
      function singleObj = getInstance
          mlock;
          persistent localObj
          if isempty(localObj) || ~isvalid(localObj)
              localObj = rfManage;
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

      function res = remove(obj, query)
          % find the index of the object required
          index = obj.index(query);
          % initialize output
          res = false;
          % remove object if it was found
          if ~isempty(index)   
              % object found, removed from memory arrays
              obj.object(index(1)) = [];
              obj.uuid(index(1)) = [];
              obj.file(index(1)) = [];
              res = true;
          end %if 
      end %function
   end
end
