#!/bin/bash -eux

if [ "$BASH" != "/bin/bash" ]; then
  echo "Please do ./$0"
  exit 1
fi

# always base everything relative to this file to make it simple
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# where the repo lives on your computer
export MDF_PROJECT_ROOT_PATH=$parent_path/..

# will be defined to whatever it was set to before, or default to user's home dir as was recommended in the readme
export MDF_CONF_PATH=${MDF_CONF_PATH:-$HOME/mdf}
matlab_version=${MATLAB_VERSION:-"R2020a"}

# install this to make sure to be able to use envsubst (used just for this script)
sudo apt-get install gettext-base

#########################################
# add some jars to the matlab classpath
matlab_configs_path=$HOME/.matlab/$matlab_version
touch $matlab_configs_path/javaclasspath.txt && \
# for now appending to the javaclasspath, so we don't erase what might already be there
# substitute any env vars within javaclasspath.txt for their actual values
echo "Copying javaclasspath.txt to: $matlab_configs_path/javaclasspath.txt"
envsubst < $parent_path/files-for-setup/javaclasspath.txt >> $matlab_configs_path/javaclasspath.txt

# to make sure it worked, can run this in the matlab console:
#
#   javaclasspath

# and then check to see if the java classes from javaclasspath.txt are there

#########################################
# setup the mdf data and conf dirs
mkdir -p $MDF_CONF_PATH/conf
mkdir -p $MDF_CONF_PATH/data
# this should already exist (I think Matlab makes it?), but just to make sure
mkdir -p ~/Documents/MATLAB/

# just need it somewhere that is on matlab's path. ~/Documents/MATLAB/ works just fine
# substitute any env vars within startMdf.m for their actual values
echo "Copying startMdf.m to: ~/Documents/MATLAB/startMdf.m"
envsubst < $parent_path/files-for-setup/startMdf.m > ~/Documents/MATLAB/startMdf.m

# provide an example working conf xml file
# substitute any env vars 
echo "Copying mdf.conf.xml to: $MDF_CONF_PATH/conf/mdf.conf.xml"
envsubst < $parent_path/files-for-setup/mdf.conf.xml > $MDF_CONF_PATH/conf/mdf.conf.xml 

# another xml file for unitTesting
echo "Copying mdf.conf.xml.for_unitTest to: $MDF_PROJECT_ROOT_PATH/mMDF/unitTest/conf/mdf.xml.conf"
envsubst < $parent_path/files-for-setup/mdf.conf.xml.for_unitTest > $MDF_PROJECT_ROOT_PATH/mMDF/unitTest/conf/mdf.xml.conf

# test that our setup script ran
echo "Checking to see if our setup script ran correctly. If there's warnings about log4j or mongo logging, that's no problem. Just make sure it says 'Done!!' at the end"
cd ~/Documents && /usr/local/MATLAB/$matlab_version/bin/matlab -batch "startMdf; exit"
