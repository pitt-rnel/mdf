function disp(obj,type)
    % function obj.disp(type)
    %
    % display object
    % input
    % - type: string indcating the type of display
    %   * c(ond(ensed)) = condensed display
    %   * r(eg(ular)), d(ef(ault)) = normal display
    %   * a(ll), e(xt(ented)) = print everything
    %   * i(nt(ernal)) = use built in disp
    %    
        
    % constants
    % label indentation
    li = 4;
    % label length first level
    ill1 = 15;
    fll1 = ['%' num2str(ill1) 's :'];
    % label length second level
    ill2 = ill1 + li;
    fll2s = ['%' num2str(ill2) 's'];
    fll2 = ['%' num2str(ill2) 's :'];
    
	% output value
    res = 1;

    % check which type of display we need to provide
    if nargin < 2
        type = 'd';
    end %if
    switch (type)
        case {'c', 'cond', 'condensed'}
            type = 'c';
        case {'r', 'reg', 'regular', 'd', 'def', 'default'}
            type = 'r';
        case {'a', 'all', 'e', 'ext', 'extended'}
            type = 'a';
        case {'i', 'int', 'internal'}
            builtin('disp',obj);
            return;
    end %switch
         
    % check if we have multiple objects in input
    if length(obj) > 1
        for i=1:length(obj)
            obj(i).disp(type);
            disp(' ');
        end %for
        return;
    end %if

    disp(' ');
    if type ~= 'c'
        % print object type
        printKeyValue('type',obj.type,ill1);
        % print object uuid
        printKeyValue('uuid',obj.uuid,ill1);
    end %if
    if type == 'a'
        % print object vuuid
        printKeyValue('vuuid',obj.vuuid,ill1);
        % print object created timestamp
        printKeyValue('created',obj.created,ill1);
        % print object modified timestamp
        printKeyValue('modified',obj.modified,ill1);

        % print object file
        %printKeyValue('file',obj.file,ill1);
    end %if
    % print data properties
    if ~isfield(obj.mdf_def,'mdf_data') || ...
            ~isfield(obj.mdf_def.mdf_data,'mdf_fields') || ...
            isempty(obj.mdf_def.mdf_data.mdf_fields)
        printKeyValue('data','[]',ill1);
    else
        printKeyValue('data','',ill1);
        for i = 1:length(obj.mdf_def.mdf_data.mdf_fields)
            % get data property name
            name = obj.mdf_def.mdf_data.mdf_fields{i};
            loaded = '';
            if type == 'a'
                loaded = 'Loaded)';
                if ~obj.status.loaded.data.(name)
                    loaded = ['Not ' loaded];
                end %if
                loaded = [' (' loaded];
            end %if
            % find how many dimensions this data property has
            dformat = repmat('%dx',1,length(obj.mdf_def.mdf_data.(name).mdf_size));
            dformat = dformat(1:end-1);
            disp(sprintf(['%' num2str(ill2) 's : [' dformat ' %s]%s'], ...
                name, ...
                obj.mdf_def.mdf_data.(name).mdf_size, ...
                obj.mdf_def.mdf_data.(name).mdf_class, ...
                loaded));
        end %for
    end %if
    
    % print metadata
    if isempty(obj.metadata) || isempty(fieldnames(obj.metadata))
        printKeyValue('metadata','[]',ill1);
    else
        % if compact view, prints only first level
        if type == 'c'
            printKeyValue('metadata','',ill1);
            % print only first level
            fl = fields(obj.metadata);
            for i = 1:length(fl)
                % get name
                name = fl{i};
                if isnumeric(obj.metadata.(name)) || ...
                        islogical(obj.metadata.(name))                        
                    % print value
                    printKeyValue(name,num2str(obj.metadata.(name)),ill2);
                elseif ischar(obj.metadata.(name))
                    % print string
                    % print only the first line and crop it to 80
                    % characters
                    tmp1 = strsplit(obj.metadata.(name),char(13));
                    printKeyValue(name,tmp1{1},ill2,80);
                else
                    % print type and size
                    dims = size(obj.metadata.(name));
                    dformat = repmat('%dx',1,length(dims));
                    dformat = dformat(1:end-1);
                    disp(sprintf(['%' num2str(ill2) 's : [' dformat ' %s]%s'], ...
                        name, ...
                        dims, ...
                        class(obj.metadata.(name))));
                end %if
            end %for
        else
            % print all levels
            printStruct('metadata',obj.metadata,ill1,li);
            % get data aready
            %printKeyValue('metadata','',ill1);
            % transform metadata in yaml string in string
            %tmp1 = strtrim(char(WriteYaml('',obj.metadata,0)));
            % define the indentation
            %tmp2 = sprintf(['%' num2str(ill2) 's'],'');
            % print with indentation
            %disp( ...
            %    regexprep( ...
            %        regexprep( ...
            %            tmp1 , '^(.)' , [tmp2 '$1'] ), ...
            %            '\n(.)' , ['\n' tmp2 '$1'] ) );
        end %if
    end %if

    % print children
    if ~isfield(obj.mdf_def,'mdf_children') || ...
            ~isfield(obj.mdf_def.mdf_children,'mdf_fields') || ...
            isempty(obj.mdf_def.mdf_children.mdf_fields)
        printKeyValue('children','[]',ill1);
    else
        printKeyValue('children','',ill1);
        % print all the children
        for i = 1:length(obj.mdf_def.mdf_children.mdf_fields)
            % extract name
            name = obj.mdf_def.mdf_children.mdf_fields{i};
            % check if the child field exists or it is only a place mark
            if isfield(obj.mdf_def.mdf_children,name) && ...
                    ~isempty(obj.mdf_def.mdf_children.mdf_types{i})
                % number of children under the same name
                nc = length(obj.mdf_def.mdf_children.(name));
                % print size and type
                printKeyValue( ...
                    name, ...
                    sprintf( ...
                        '[%d %s]', ...
                        nc, ...
                        obj.mdf_def.mdf_children.mdf_types{i}), ...
                    ill2);
                if type == 'a'
                    % print all children of the same type
                    for j = 1:nc
                        disp(sprintf(['%' num2str(ill2) 's   %s %s'], ...
                            '', ...
                            obj.mdf_def.mdf_children.(name)(j).mdf_uuid, ...
                            obj.mdf_def.mdf_children.(name)(j).mdf_file));
                    end %for
                end %if
            else
                % print only placemark
                printKeyValue(name,'[0 unknown]',ill2);
            end %if
        end %for
    end %if

    % print links
    if ~isfield(obj.mdf_def,'mdf_links') || ...
            ~isfield(obj.mdf_def.mdf_links,'mdf_fields') || ...
            isempty(obj.mdf_def.mdf_links.mdf_fields)
        printKeyValue('links','[]',ill1);
    else
        printKeyValue('links','',ill1);
        % print all the children
        for i = 1:length(obj.mdf_def.mdf_links.mdf_fields)
            % extract name
            name = obj.mdf_def.mdf_links.mdf_fields{i};
            % check if the link field exists or it is only a place mark
            if isfield(obj.mdf_def.mdf_links,name) && ...
                    ~isempty(obj.mdf_def.mdf_links.mdf_types{i}) && ...
                    ~isempty(obj.mdf_def.mdf_links.mdf_directions{i})
                % number of link under the same name
                nc = length(obj.mdf_def.mdf_links.(name));
                % print size and obj type and directionality
                printKeyValue( ...
                    name, ...
                    sprintf( ...
                        '[%d %s %s]', ...
                        nc, ...
                        obj.mdf_def.mdf_links.mdf_types{i}, ...
                        obj.mdf_def.mdf_links.mdf_directions{i}), ...
                    ill2);
                if type == 'a'
                    % print all children of the same type
                    for j = 1:nc
                        disp(sprintf(['%' num2str(ill2) 's   %s %s'], ...
                            '', ...
                            obj.mdf_def.mdf_links.(name)(j).mdf_uuid, ...
                            obj.mdf_def.mdf_links.(name)(j).mdf_file));
                    end %for
                end %if
            else
                % print only placemark
                printKeyValue(name,'[0 unknown]',ill2);
            end %if
        end %for
    end %if

    % print parent
    if type == 'a'
        if isempty(obj.mdf_def.mdf_parents) || ...
                isempty(fields(obj.mdf_def.mdf_parents))
            printKeyValue('parents','[]',ill1);
        else
            printKeyValue('parents','',ill1);
            % plot all parents
            for i = 1:length(obj.mdf_def.mdf_parents)
                % extract parent information
                p = obj.mdf_def.mdf_parents(i);
                % display
                printKeyValue(p.mdf_type,p.mdf_uuid,ill2);
                if type == 'a'
                    disp(sprintf(['%' num2str(ill2) '   %s]'], ...
                        '',p.mdf_file));
                end %if
            end %for
        end %if
    end %if
end %function

function printKeyValue(key, value, keySize, valueSize)  
    % function printKeyValue(key, value, keySize, valueSize)
    %
    % print key value separated by :
    % if sizes are specified, key and/or value get trimmed to specified
    % size
    %
    
    % check if we got sizes
    if nargin < 2
        throw( ...
            MException( 'mdfObj.disp.printKeyValue', 'Not enough input arguments'));
    end %if
    if nargin < 3
        keySize = -1;
    end %if
    if nargin < 4
        valueSize = -1;
    end %if
            
    
    % format string and trim key and value if needed
    fs = '%';
    kd = key;
    vd = value;
    if keySize > 0
        % format string
        fs = [fs num2str(keySize)];
        % key to display
        if length(kd) > keySize 
            kd = [kd(1:(keySize-3)) '...'];
        end %if
    end %if
    if ~isempty(kd) && length(kd) > 0
        fs = [fs 's : %-'];
    else
        fs = [fs 's   %-'];
    end %if
    if valueSize > 0
        % format string
        fs = [fs num2str(valueSize)];
        % key to display
        if length(value) > valueSize 
            vd = [vd(1:(valueSize-3)) '...'];
        end %if        
    end %if
    fs = [fs 's'];
    % print on screen
    disp(sprintf(fs, kd, vd))
end % function

function printStruct(key, value, keySize, delta, valueSize)
    % function printStruct(key, value, keySize, delta, valueSize)
    %
    % print recursively the structure passed in
    
    % check inputs
    if nargin < 3
        throw( ...
            MException( 'mdfObj.disp.printStruct', 'Not enough input arguments'));        
    end %if
    if nargin < 4
        delta = 2;
    end %if
    if nargin < 5
        valueSize = -1;
    end %if
    
    % get size of value
    dims = size(value);
    % prepare format string for size
	dformat = repmat('%dx',1,length(dims));
    dformat = dformat(1:end-1);
    
    % check which type we have
    if isstruct(value)
        % print label
        printKeyValue(key,'',keySize);
        % get list of fields
        fieldList = fields(value);
        % loop on field list
        for i = 1:length(fieldList)
            field = fieldList{i};
            printStruct(field,value.(field),keySize+delta,delta,max(-1,valueSize-delta));
        end %for
    elseif isnumeric(value) || islogical(value)
        % check which is the size of the value
        if max(size(value)) == 1
            % print value
            printKeyValue(key,num2str(value),keySize,valueSize);
        else
            % print size and type
            printKeyValue( ...
                key, ...
                sprintf(['[' dformat ' %s]'], dims, class(value)), ...
                keySize, ...
                valueSize);
        end %if
    elseif iscell(value)
        % print size and type
        printKeyValue( ...
        	key, ...
            sprintf(['[' dformat ' %s]'], dims, class(value)), ...
            keySize, ...
            valueSize);
    elseif ischar(value)
        % print string
        % print every line and crop each one to 80
        % characters
        stringLength = 80;
        if valueSize > 0
            stringLength = min(80,valueSize)
        end %if
        % compress and remove duplicated new lines
        tmp1 = double(value);
        tmp1(tmp1==10) = [];
        tmp1 = char(tmp1);
        tmp1 = strsplit(tmp1,char(13));
        if length(tmp1) == 1
            printKeyValue(key,tmp1{1},keySize,stringLength);
        else
            printKeyValue( key, '', keySize);
            for i = 1:length(tmp1)
                printKeyValue('',tmp1{i},keySize,stringLength);
            end %for
        end %if
            
    else
    	% print anything else
        printKeyValue( ...
        	key, ...
            sprintf(['[' dformat ' %s]'], dims, class(value)), ...
            keySize, ...
            valueSize);
    end %if
end %function
