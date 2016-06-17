function mjbStartup(obj)
    % startup function for MJB
    %
    
    % get configuration name
    conf = obj.getSelection;
    
    % startup messages
    fprintf('Current configuration: %s\n',conf);
    set(0,'DefaultTextInterpreter','none');
    warning('off','MATLAB:dispatcher:InexactCaseMatch');
    warning('off','MATLAB:dispatcher:nameConflict');
    warning('off','MATLAB:print:Illustrator:DeprecatedDevice');
        
    addpath_recurse(DROPBOX,{'archive' 'demos' 'documentation' 'doc' 'test' 'bin'});
        
    format longG;
    rng('shuffle');
        
    hideStartBar
    enableDeleteByWord
        
    setDefaultEditor
        
    dbstop if error
end

function setDefaultEditor
	if ~usejava('desktop') && usejava('jvm')
    	com.mathworks.services.Prefs.setBooleanPref('EditorBuiltinEditor',false)
        com.mathworks.services.Prefs.setStringPref('EditorOtherEditor','subl')
    elseif usejava('jvm')
    	com.mathworks.services.Prefs.setBooleanPref('EditorBuiltinEditor',true)
    	com.mathworks.services.Prefs.setStringPref('EditorOtherEditor','')            
    end
end
