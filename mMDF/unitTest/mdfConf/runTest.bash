#!/bin/bash
#
# run unit test on mdfConf matlab version
if [ "-`alias`-" == "--" ]; then
  echo "You need to run this script withthe source command:"
  echo "> source $0"
  exit
fi
matlab -nodesktop -nosplash -nodisplay -r "runTest; quit"
