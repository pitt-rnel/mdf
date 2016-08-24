function res = size(obj)
   % function res = obj.size()
   %
   % return size in bytes of the data contained in the object
   % it is a wrapper function for getSize

   res = obj.getSize()
end %function
