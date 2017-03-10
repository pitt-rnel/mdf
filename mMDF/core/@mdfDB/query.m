function res = query(obj,indata)
    % function res = obj.query(indata)
    %
    % run queries on habitats and returns results
    %
    % input
    % - indata: (string or struct) individual query with no habitat specified. 
    %           Internally it's transformed in the second type
    %           (cell array)
    %           each cell should be on eof the following cases 
    %           1) string: could be a uuid, a file or a query already in native format
    %           2) struct without fields habuuid and query: this is a query in struct format.
    %                      the habitat will take care of convert it to native format
    %           3) struct without field habuuid by with field query:
    %                      this is similar to case #2
    %           4) struct with field habuuid and query: here we know which habitat 
    %                      we need to run this query on. 
    %                      Query can be string uuid, file path, query or struct query
    %
    %    
    %
    % output
    % - res: 0 if no results have been found
    %        cell of json strings representing the objects found
    %

    res = 0;

    % makes sure that indata is a cell array
    if ~iscell(indata)
        indata = {indata};
    end %if
 
    % preprocess indata
    % query queue
    qq = struct( 'habs', struct() , queries,'blind', {} );
    % it makes sure that all the items are a structure with followinf items
    for i1 = 1:length(indata)
        % extract query item
        item = indata{i1};
        % check if it is a string
        if isa(item,'char')
            % transform into correct structure
            item = struct('habuuid',[],'query',item);
        end %if
        if isa(item,'struct') && ~isfield(item,'query')
            % transform into correct structure
            item = struct('hbuuid',[],'query', item);
        end %if
        if ~isfield(item,'habuuid') || isempty(item.habuuid)
            % no habitat specified
            qq.blind{end+1} = item.query;
        else
            % we got the habitat
            hkey = ['uuid_' item.habuuid]; 
            % check if we already hav a list for this habitat
            if ~isfield(qq.habs,hkey)
                % crate an empty list for this habitat
                qq.habs.(hkey) = struct( ...
                    'habuuid', item.habuuid, ...
                    'queries', {});
            end %if
            % insert query for this habitat
            qq.habs.(hkey).queries{end+1} = item.query;
        end %if
         
    end %for

    % temporary place holder for results
    tres = {};

    % first takes care of all the queries on specific habitats
    fl = fields(qq.habs);
    for i1 = 1:length(fl)
        % get habitat object
        ohab = obj.getH(qq.habs.(fl(i1)).habuuid);
        % run queries on habitat
        tres{end+1} = ohab.query(qq.habs.(fl(i1)).queries);
    end %for

    
    % loops on all the blind queries
    for i1 = 1:length(qq.blind)

        % order habitats. first the ones that are connected
        % redo the searhc at every iteration because 
        % connected habitats my change with each query
        connected = cellfun(@(k) obj.habitats.byuuid.(k).getsqrw(),obj.habitats.uuids));
        [~,order] = sort(connected,1,'descend');
        uuids = obj,habitats.uuids(order);

        % local temporary result
        ltres = {};
        % loops on every habitats and run query until it finds something
        for i2 = 1:length(uuids)
            % gets habitat object
            ohab = obj.getH(uuids(i2));
            %   
            % query habitat
            ltres = obj.habitats.bytype.t_db(i2).query( qq.blind{i1} );
            % stop searching when it finds something
            if ~isempty(ltres)
                % insert results in temporary complete list
                tres{end+1} = ltres;
                % exit loop for this query
                break;
            end %if
        end %for
    end %for

    res = tres;
    
end %function
