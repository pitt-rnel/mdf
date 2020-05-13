%
% this script is a wrapper to run the test once matlab is started
%
% Create test object for mdfObj with first configuration
testMdfObjConf1 = mdfObjConf1Test;

% Run tests using dot notation
resultsMdfObj1 = testMdfObjConf1.run;
 
% Create test object for mdfObj with second configuration
testMdfObjConf2 = mdfObjConf2Test;

% Run tests using dot notation
resultsMdfObj2 = testMdfObjConf2.run;
 
% Create test object for mdfObj with third configuration
testMdfObjConf3 = mdfObjConf3Test;

% Run tests using dot notation
resultsMdfObj3 = testMdfObjConf3.run;
 

% display results
resultsMdfObj = [resultsMdfObj1, resultsMdfObj2, resultsMdfObj3]

clear resultsMdfObj1 resultsMdfObj2 resultsMdfObj3

