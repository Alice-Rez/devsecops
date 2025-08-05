#!/bin/bash

set -eo pipefail

JENKINS_URL='http://localhost:8080'
USER="alice"
PASS="ZirafkaHadi"

COOKIE_FILE=$(mktemp /tmp/jenkins_cookie.XXXXXX)
trap 'rm -f "$COOKIE_FILE"' EXIT

JENKINS_CRUMB=$(curl -sSf -u "$USER:$PASS" \
  --cookie-jar "$COOKIE_FILE" \
  "$JENKINS_URL/crumbIssuer/api/json" \
  | jq -r '.crumb')

JENKINS_TOKEN=$(curl -sSf -u "$USER:$PASS" \
  --cookie "$COOKIE_FILE" \
  -H "Jenkins-Crumb:$JENKINS_CRUMB" \
  -X POST \
  --data-urlencode "newTokenName=demo-token66" \
  "$JENKINS_URL/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
  | jq -r '.data.tokenValue')

echo $JENKINS_URL
echo $JENKINS_CRUMB
echo $JENKINS_TOKEN

while read plugin; do
   echo "........Installing ${plugin} .."
   curl -s POST --data "<jenkins><install plugin='${plugin}' /></jenkins>" -H 'Content-Type: text/xml' "$JENKINS_URL/pluginManager/installNecessaryPlugins" --user "alice:$JENKINS_TOKEN"
done < plugins.txt


#### we also need to do a restart for some plugins

#### check all plugins installed in jenkins
# 
# http://<jenkins-url>/script

# Jenkins.instance.pluginManager.plugins.each{
#   plugin -> 
#     println ("${plugin.getDisplayName()} (${plugin.getShortName()}): ${plugin.getVersion()}")
# }


#### Check for updates/errors - http://<jenkins-url>/updateCenter
