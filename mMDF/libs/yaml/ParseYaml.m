%==========================================================================
% Read a yaml string and returns a matlab struct
%
% Input:
%   yamlIn           ... yaml string in input
%
% Output:
%   yamlOut          ... yaml as matlab struct
%
function yamlOut = ParseYaml(yamlIn,makeords,dictionary)

%     % tries to import yaml java library
%     try
%         % import yaml java library
%         import('org.yaml.snakeyaml.*');
%         javaObject('Yaml');
%     catch
%         % no luck
%         % find full path of this yaml library
%         [pth,~,~] = fileparts(mfilename('fullpath'));       
%         % build path to jar library
%         dp = [pth filesep 'external' filesep 'snakeyaml-1.9.jar'];
%         if not(ismember(dp, javaclasspath ('-dynamic')))
%             % add path to java library
%         	javaaddpath(dp); % javaaddpath clears global variables...!?
%         end
%         % import java library
%         import('org.yaml.snakeyaml.*');
%     end; % try/catch
    
    % instantiate yaml java object
    yaml = org.yaml.snakeyaml.Yaml(); % It appears that Java objects cannot be persistent...!?
    % load our yaml in the instance
    jYaml = yaml.load(yamlIn);
    % scan the object and transform it to matlab struct
    yo = scan_yaml(jYaml);
    % does some other magic
    yo = deflateimports(yo);
    if iscell(yo) && ...
        length(yo) == 1 && ...
        isstruct(yo{1}) && ...
        length(fields(yo{1})) == 1 && ...
        isfield(yo{1},'import')        
        yo = yo{1};
    end;
    yo = mergeimports(yo);    
    yo = doinheritance(yo);
    if exist('makeords','var')
        yo = makematrices(yo, makeords);    
    end; %if
    if exist('dictionary','var')
        yo = dosubstitution(yo, dictionary);
    end; %if
    
    yamlOut = yo;

end % function