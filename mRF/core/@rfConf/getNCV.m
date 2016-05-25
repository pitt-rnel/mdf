function C = getNCV(obj,selection,level)
    % C = rfconf.getNCV(obj,selection)
    %
    % return the selected nested configuration constant value
    %
    % output
    %   C = (struct) configuration data
    % input
    %   obj = this object
    %   selection = (string,cell) selected keys
    %
    
    if nargin < 2
        throw(MException('rfconf:getNCV','Please specify keys selection'));
    end %if
    
    if nargin < 3
        % no level, get all the constant structure
        
        % use getConf
        level = obj.getConf();
    end %if
    
    % check if selection is a string
    if isa(selection,'char')
        % split selection in separate keys and call itself
        C = obj.getNCV(strsplit(selection,'.'),level);
    elseif isa(selection,'cell')
        % here is the core
        lk = selection{1};
        selection(1) = [];
        % decide next level
        nl = [];
        if isa(level,'struct') && isfield(level,lk)
            nl = level.(lk);
        end
        % check if we need to go deeper
        if ~isempty(nl) && length(selection) > 0
            % go deeper
            C = obj(selection,nl);
        elseif ~isempty(nl) && length(selection) == 0
            % found waht we were looking for
            C = nl;
        else
            throw(MException('rfconf:getNCV','Cosntants not found'));
        end %if
    end %if
end %function