%
% this script is a wrapper to run the test once matlab is started
%
% Create test object for mdfConf
testMdfConf = mdfConfTest;

% Run tests using dot notation
resultsMdfConf = testMdfConf.run; 

% display results
resultsMdfConf

