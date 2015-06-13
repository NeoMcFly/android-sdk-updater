#!/bin/bash

if [ $# -eq 0 ]
then
  echo "Please specify the android home path" >&2
  exit 1
fi

ANDROID_SDK=$1/tools/android

shift 1

ARGS="$@"

FILTERS="platform,tool,platform-tool,extra,add-on,source"

function update(){

  echo "$ANDROID_SDK update sdk --no-ui $@"

  expect -c "
  set timeout -1   ;
  spawn $ANDROID_SDK update sdk --no-ui $@
  expect {
      \"Do you accept the license\" { exp_send \"y\r\" ; exp_continue }
     eof
  }
  "
}

# Check for Build-tools availability 
BUILD_TOOLS_FILTER=$($ANDROID_SDK --clear-cache list sdk | grep -i build-tools | head -n 1 | cut -d '-' -f 1)
if [ -z "$BUILD_TOOLS_FILTER" ]
then
  echo "Build-tools is already installed and up to date"
else
  # Look for the build-tools id
  BUILD_TOOLS_FILTER=$($ANDROID_SDK list sdk --all | grep -i build-tools | grep -v rc | head -n 1 | cut -d '-' -f 1)  
  echo "Build-tools have to be updated '$BUILD_TOOLS_FILTER' "
  update "--all -t $BUILD_TOOLS_FILTER"
fi

# Update the rest
update "$ARGS -t $FILTERS"

