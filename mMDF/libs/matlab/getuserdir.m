function userDir = getuserdir
    %GETUSERDIR   return the user home directory.
    %   function USERDIR = GETUSERDIR returns the user home directory using the registry
    %   on windows systems and using Java on non windows systems as a string
    %
    %   Example:
    %      getuserdir() returns on windows
    %           C:\Documents and Settings\MyName\Eigene Dateien
    %
    % downloaded from MAthWorks File Exchange
    % - http://www.mathworks.com/matlabcentral/fileexchange/15885-get-user-home-directory/content/getuserdir.m
    % - http://www.mathworks.com/matlabcentral/fileexchange/15885-get-user-home-directory
    %
    % Author: Sven Probst (http://www.mathworks.com/matlabcentral/profile/authors/870000-sven-probst)
    % 

    if ispc
        userDir = winqueryreg('HKEY_CURRENT_USER',...
            ['Software\Microsoft\Windows\CurrentVersion\' ...
             'Explorer\Shell Folders'],'Personal');
    else
        userDir = char(java.lang.System.getProperty('user.home'));
    end %if
end %function
