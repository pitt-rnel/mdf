function res = size(obj)
   % function res = obj.size()
   %
   % if obj is an array, it will return the size of the obj array
   % if obj is a single mdfObj, it will 
   % return size in bytes of the data contained in the object
   % it is a wrapper function for getSize

   % lets' check if obj is an array of mdfObj or a single mdfObj
   if max(builtin('size',obj)) > 1
       % we have a vector or a matrix
       %
       % return the size of the mdfObj array/matrix
       res = builtin('size',obj);
   else
       % return the size of the mdfObj in memory
       res = obj.getSize();
   end %if
end %function
