function outdata = load(varargin)
    % function outdata = mdf.load(indata...)
    %
    % this function is a wrapper for mdfObj.load.
    %
    % Input:
    %   - (string): uuid of the object that we would like to load
    %   - (struct): structure with query fields and associated values
    %               please see mdfObj.load for additional help
    %   - list of pairs field,values to be translated in a struct, like in
    %               the previous input. lengh of the list needs to be even
    %
    % please see mdfObj.load for additional help
    
    outdata = [];
    indata = [];
    
    if nargin == 1
        indata = varargin{1};
    elseif mod(nargin,2) ~= 0
        disp('Number of input arguments should be 1 or an even number of elements');
        return
    else
        % convert input cell to struct
        indata = struct();
        for i=1:2:nargin
            % makes sure we are not dealing with strings but just with
            % array of chars
            key = char(varargin{i});
            value = varargin{i+1};
            if isstr(value)
                value = char(value);
            end %if
            indata.(key) = value;
        end %for
    end %if
    
    outdata = mdfObj.load(indata);
end