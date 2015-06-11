#!/bin/bash

if [ $# -eq 0 ]
then
	echo "Please specify the android home path" >&2
	exit 1
fi

ANDROID_SDK=$1/tools/android

shift 1

ARGS="--no-ui $@"

FILTERS="platform,tool,platform-tool,extra,add-on,source"

# Cache the update list
echo "Caching the update list..."
"$ANDROID_SDK" --clear-cache list sdk $ARGS
echo "ok"

# Look for the build-tools id
BUILD_TOOLS_FILTER=$($ANDROID_SDK list sdk $ARGS | grep "Build-tools" | head -n 1 | cut -d '-' -f 1)
if [ -z "$BUILD_TOOLS_FILTER" ]
then
  echo "Build-tools is already installed and up to date"
else
  echo "Build-tools have to be updated '$BUILD_TOOLS_FILTER' "
  FILTERS="$BUILD_TOOLS_FILTER,$FILTERS "
fi

expect -c "
set timeout -1   ;
spawn $ANDROID_SDK update sdk $ARGS -t $FILTERS
expect {
    \"Do you accept the license\" { exp_send \"y\r\" ; exp_continue }
    eof
}
"
