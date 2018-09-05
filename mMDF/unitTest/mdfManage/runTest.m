%
% this script is a wrapper to run the test once matlab is started
%
% Create test object for mdfConf
testMdfManage = mdfManageTest;

% Run tests using dot notation
resultsMdfManage = testMdfManage.run; 

% display results
resultsMdfManage

