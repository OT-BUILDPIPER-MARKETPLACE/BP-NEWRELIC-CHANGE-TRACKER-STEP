#!/bin/bash

source functions.sh
source log-functions.sh
source str-functions.sh
source file-functions.sh
source aws-functions.sh

ENTITY_GUID=$(getNewrelicGuid)

sleep $SLEEP_DURATION

logInfoMessage "I'll create a Deployment tracking successful for entity GUID: ${ENTITY_GUID}"

newrelic profile add --profile "${NEW_RELIC_PROFILE}" --region "${NEW_RELIC_REGION}" --apiKey "${NEW_RELIC_API_KEY}" --accountId "${NEW_RELIC_ACCOUNT_ID}" --licenseKey "${NEW_RELIC_LICENSE_KEY}"

if ! newrelic profile list | grep -q "${NEW_RELIC_PROFILE}"; then
    logErrorMessage "Error: New Relic CLI is not authenticated with the profile '${NEW_RELIC_PROFILE}'."
    exit 1
fi

VERSION=$(getDeploymentImage)
GIT_URL=$(getDeploymentGitUrl)
GIT_BRANCH=$(getDeploymentGitBranch)
GIT_COMMIT_MSG=$(getGitCommitMsg)
GIT_COMMIT_SHA=$(getGitCommitSha)                                                                                                                                                                                                                                                                                                                                                               
DESCRIPTION="Deploy Details :- gitUrl: $GIT_URL, gitBranch: $GIT_BRANCH, gitCommitSha: $GIT_COMMIT_SHA, gitCommitMsg: $GIT_COMMIT_MSG, dockerImage: ${VERSION}"
USER=$(getDeploymentUser)
TIMESTAMP=$(getDeploymentTimestamp)                                                                                                                                                                             

if newrelic entity deployment create --guid "${ENTITY_GUID}" --version "${VERSION}" \
  --description "${DESCRIPTION}" --user "${USER}" --deploymentType "${DEPLOYMENT_TYPE}" \
  --timestamp "${TIMESTAMP}"
then
  logInfoMessage "Deployment tracking successful for entity GUID: ${ENTITY_GUID}."
  generateOutput $ACTIVITY_SUB_TASK_CODE true "Deployment tracking successful for entity GUID: ${ENTITY_GUID}."
else
  logErrorMessage "Deployment tracking failed for entity GUID: ${ENTITY_GUID}."
  generateOutput $ACTIVITY_SUB_TASK_CODE false "Deployment tracking failed for entity GUID: ${ENTITY_GUID}."
fi
