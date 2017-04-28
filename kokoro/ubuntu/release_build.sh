#!/bin/bash

# Fail on any error.
set -e
# Display commands to stderr.
set -x

cd github/app-maven-plugin
sudo /opt/google-cloud-sdk/bin/gcloud components update
sudo /opt/google-cloud-sdk/bin/gcloud components install app-engine-java
mvn -Prelease -B -U verify
# copy pom with the name extected in the Maven repository
cp pom.xml target/`mvn help:evaluate -Dexpression=project.artifactId | grep -v "^\["`-`mvn help:evaluate -Dexpression=project.version | grep -v "^\["`.pom
