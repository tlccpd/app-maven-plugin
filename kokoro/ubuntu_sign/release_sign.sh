#!/bin/bash

# Fail on any error.
set -e
# Display commands being run.
set -x

cd $KOKORO_GFILE_DIR
mkdir signed && chmod 777 signed

# find the latest directory under prod/app-maven-plugin/gcp_ubuntu/release/
LAST_BUILD=$(ls prod/app-maven-plugin/gcp_ubuntu/release/ | sort -rV | head -1)
# find regular files under the directory, assumption is that only the jars and
# the pom are there
FILES=$(find `pwd`/prod/app-maven-plugin/gcp_ubuntu/release/${LAST_BUILD}/* -type f)
for f in $FILES
do
  echo "Processing $f file..."
  filename=$(basename "$f")
  if /escalated_sign/escalated_sign.py -j /escalated_sign_jobs -t linux_gpg_sign \
    $f
  then echo "Signed $filename"
  else
    echo "Could not sign $filename"
    exit 1
  fi
done

ls -lart
