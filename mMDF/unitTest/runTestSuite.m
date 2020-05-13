%
% this matlab script run the complete battery of test for all the mdf components
%
% by: Max Novelli
%     man8@pitt.edu
%     2018/10/16
%

% tests need to be run in a specific order
% mdfConf
disp('Running mdfConf unit tests...');
cd mdfConf
pwd
runTest
cd ..

% mdfDB
disp('Running mdfDB unit tests...');
cd mdfDB
pwd
runTest
cd ..

% mdfManage
disp('Running mdfManage unit tests...');
cd mdfManage
pwd
runTest
cd ..

% mdfObj
disp('Running mdfObj unit tests...');
cd mdfObj
pwd
runTest
cd ..

% mdf
disp('Running mdf unit tests...');
cd mdf
pwd
runTest
cd ..

% combine results
results= struct( ...
    'mdfConf', resultsMdfConf, ...
    'mdfDB', resultsMdfDB, ...
    'mdfManage', resultsMdfManage, ...
    'mdfObj', resultsMdfObj, ...
    'mdf', resultsMdf ...
);

resultsAll = [ resultsMdfConf, resultsMdfDB, resultsMdfManage, resultsMdfObj, resultsMdf];

info = struct( ...
    'tests', length(resultsAll), ...
    'passed', sum([resultsAll.Passed]), ...
    'failed', sum(~[resultsAll.Passed]));

clear resultsMdfConf resultsMdfDB resultsMdfManage resultsMdfObj resultsMdf
