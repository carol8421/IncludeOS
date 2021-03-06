#!/bin/bash

# Script that builds all the files in the example folder
# Will print the output if the test fails

set -eE

export INCLUDEOS_PREFIX=${INCLUDEOS_PREFIX:-/usr/local}

tmpfile=/tmp/build_test

trap fail ERR
function fail {
  echo "[ FAIL ]"
  cat $tmpfile
  exit 1
}

function getScriptAbsoluteDir {
    # @description used to get the script path
    # @param $1 the script $0 parameter
    local script_invoke_path="$1"
    local cwd=`pwd`

    # absolute path ? if so, the first character is a /
    if test "x${script_invoke_path:0:1}" = 'x/'
    then
        RESULT=`dirname "$script_invoke_path"`
    else
        RESULT=`dirname "$cwd/$script_invoke_path"`
    fi
}

script_invoke_path="$0"
getScriptAbsoluteDir "$script_invoke_path"
script_absolute_dir=$RESULT
skip_tests="demo_linux"	# Tests to skip

export num_jobs=${num_jobs:--j}
echo -e ">>> Building all examples."

BREAK=""
function build_service() {
  cd $1
  BASE=`basename $1`
  str=">>> Now making $BASE"
  printf "%-50s " "* $BASE"
  git submodule update --init --recursive
  $INCLUDEOS_PREFIX/bin/boot -cb . &> $tmpfile
  echo "[ PASS ]"
}

for dir in `ls -d $script_absolute_dir/../../../examples/*`
do
  if [[ $dir == *"$skip_tests"* ]]; then
	  continue
  fi
  build_service "$dir"
done

echo "Done"
