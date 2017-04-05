%==========================================================================
% Reads YAML file, converts YAML sequences to MATLAB cell columns and YAML
% mappings to MATLAB structs
%
%  filename ... name of yaml file to be imported
%  verbose  ... verbosity level (0 or absent = no messages, 
%                                          1 = notify imports)
%==========================================================================
function result = ReadYamlRaw(filename, verbose, nosuchfileaction, treatasdata)
    if ~exist('verbose','var')
        verbose = 0;
    end;
    
    if ~exist('nosuchfileaction','var')
        nosuchfileaction = 0;
    end;
    if ~ismember(nosuchfileaction,[0,1])
        error('nosuchfileexception parameter must be 0,1 or missing.');
    end;
    
    if(~exist('treatasdata','var'))
        treatasdata = 0;
    end;
    if ~ismember(treatasdata,[0,1])
        error('treatasdata parameter must be 0,1 or missing.');
    end;
    
    [pth,~,~] = fileparts(mfilename('fullpath'));       
    try
        import('org.yaml.snakeyaml.*');
        javaObject('Yaml');
    catch
        dp = [pth filesep 'external' filesep 'snakeyaml-1.9.jar'];
        if not(ismember(dp, javaclasspath ('-dynamic')))
        	javaaddpath(dp); % javaaddpath clears global variables...!?
        end
        import('org.yaml.snakeyaml.*');
    end;
    
    setverblevel(verbose);
    % import('org.yaml.snakeyaml.Yaml'); % import here does not affect import in load_yaml ...!?
    result = load_yaml(filename, nosuchfileaction, treatasdata);
end

%--------------------------------------------------------------------------
% Actually performs YAML load. 
%  - If this is a first call during recursion it changes cwd to the path of
%  given filename and stores the old path. Then it calls the YAML parser
%  and runs the recursive transformation. After transformation or when an
%  error occurs, it sets cwd back to the stored value.
%  - Otherwise just calls the parser and runs the transformation.
%
function result = load_yaml(inputfilename, nosuchfileaction, treatasdata)

    persistent nsfe;

    if exist('nosuchfileaction','var') %isempty(nsfe) && 
        nsfe = nosuchfileaction;
    end;
    
    persistent tadf;
    
    if isempty(tadf) && exist('treatasdata','var')
        tadf = treatasdata;
    end;
   
    yaml = org.yaml.snakeyaml.Yaml(); % It appears that Java objects cannot be persistent...!?
    if ~tadf
        [filepath, filename, fileext] = fileparts(inputfilename);
        if isempty(filepath)
            pathstore = cd();
        else
            pathstore = cd(filepath);
        end;
    end;
    try
        if ~tadf
            result = scan_yaml(yaml.load(fileread([filename, fileext])));
        else
            result = scan_yaml(yaml.load(inputfilename));
        end;
    catch ex
        if ~tadf
            cd(pathstore);
        end;
        switch ex.identifier
            case 'MATLAB:fileread:cannotOpenFile'
                if nsfe == 1
                    error('MATLAB:MATYAML:FileNotFound', ['No such file to read: ',filename,fileext]);
                elseif nsfe == 0
                    warning('MATLAB:MATYAML:FileNotFound', ['No such file to read: ',filename,fileext]);
                    result = struct();
                    return;
                end;
        end;
        rethrow(ex);
    end;
    if ~tadf
        cd(pathstore);    
    end;
end

%--------------------------------------------------------------------------
% Sets verbosity level for all load_yaml infos.
%
function setverblevel(level)
    global verbose_readyaml;
    verbose_readyaml = 0;
    if exist('level','var')
        verbose_readyaml = level;
    end;
end

%--------------------------------------------------------------------------
% Returns current verbosity level.
%
function result = getverblevel()
    global verbose_readyaml; 
    result = verbose_readyaml;
end

%--------------------------------------------------------------------------
% For debugging purposes. Displays a message as level is more than or equal
% the current verbosity level.
%
function info(level, text, value_to_display)
    if getverblevel() >= level
        fprintf(text);
        if exist('value_to_display','var')
            disp(value_to_display);
        else
            fprintf('\n');
        end;
    end;
end
%==========================================================================

