function outdata = getCollStats(obj,varargin)
    % function outdata = obj.getCollStats
    %
    % return which mdf type are present in the collection that we are
    % connected to and how many of each
    %
    % input
    % - table  (boolean): should the results be printed in tabular form
    %                     Default: false
    %
    % output
    % - outdata (array of struct): 
    %                     each element specify the mdf_type of the objects
    %                     found and how many have been found
    %                     keys: mdf_type, value
    %
    
    % check if user specified table argument
    table = false;
    if nargin >= 2
        table = varargin{1};
    end %if
    
    % java object MapReduceOutput
    mrOutput = obj.coll.mapReduce( ...
        'function() { emit( this.mdf_def.mdf_type, 1 )}', ...
        'function(key, values) { return Array.sum(values) }');
    
    % get object iterator
    mrIterator = mrOutput.iterator();
    
    % if we got results, we transform them in structure and we pass it back as a cell array
    outdata = {};
    % loop until we transfer all the returned objects
    while mrIterator.hasNext()
        % get next element in list
        ele = mrIterator.next();
        % convert it to structure throught json
        outdata{length(outdata)+1} = mdf.fromJson(char(ele.toJson()));
    end %while
    % convert cell array to struct array
    outdata = cell2mat(outdata);
    % rename _id field to mdf_type
    [outdata.mdf_type] = outdata.x_id;
    outdata = rmfield(outdata,'x_id');
    
    if table
        format = '%20s %10';
        disp(sprintf([format,'s'],'MDF object type','Quantity'));
        disp(sprintf([format,'s'],'--------------------','----------'));
        arrayfun(@(item) disp(sprintf([format, 'd'],item.mdf_type,item.value)),outdata);
    end %if
end %function
