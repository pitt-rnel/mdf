%
% this script is a wrapper to run the test once matlab is started
%
% Create test object for mdfConf
testMdfDB = mdfDBTest;

% Run tests using dot notation
resultsMdfDB = testMdfDB.run; 

% display results
resultsMdfDB

