#!/bin/bash

source functions.sh
source log-functions.sh
source str-functions.sh
source file-functions.sh
source aws-functions.sh

APM_NAME=$(getNewrelicApm)
VERSION=$(getDeploymentImage)
GIT_URL=$(getDeploymentGitUrl)
GIT_BRANCH=$(getDeploymentGitBranch)
GIT_COMMIT_MSG=$(getGitCommitMsg)
GIT_COMMIT_SHA=$(getGitCommitSha)                                                                                                                                                                                                                                                                                                                                                               
USER=$(getDeploymentUser)

DESCRIPTION="Deploy Details :- gitUrl: $GIT_URL, gitBranch: $GIT_BRANCH, gitCommitSha: $GIT_COMMIT_SHA, gitCommitMsg: $GIT_COMMIT_MSG, dockerImage: ${VERSION}"

sleep $SLEEP_DURATION

logInfoMessage "I will update deployment change tracking"

newrelic profile add --profile "${NEW_RELIC_PROFILE}" --region "${NEW_RELIC_REGION}" --apiKey "${NEW_RELIC_API_KEY}" --accountId "${NEW_RELIC_ACCOUNT_ID}" --licenseKey "${NEW_RELIC_LICENSE_KEY}" > /dev/null 2>&1

if ! newrelic profile list | grep -q "${NEW_RELIC_PROFILE}"; then
    logErrorMessage "Failed to authenticate with New Relic CLI."
    exit 1
else
    logInfoMessage "Successfully authenticated with New Relic CLI."
fi

if ! ENTITY_INFO=$(newrelic entity search --name "$APM_NAME"); then
    logErrorMessage "Failed to retrieve entity information from New Relic. Please check your authentication and Entity NAME."
    exit 1
else
    logInfoMessage "Successfully retrieved entity information from New Relic."
fi

if ! ENTITY_GUID=$(echo "$ENTITY_INFO" | jq -r .guid); then
    logErrorMessage "Failed to extract ENTITY_GUID from New Relic entity information. Please ensure the Entity NAME is correct and valid data is returned."
    exit 1
else
    logInfoMessage "Successfully extracted ENTITY_GUID: $ENTITY_GUID from the entity information."
fi

logInfoMessage "Entity NAME: ${APM_NAME}"
logInfoMessage "Entity GUID: ${ENTITY_GUID}"

if newrelic entity deployment create --guid "${ENTITY_GUID}" --version "${VERSION}" \
  --description "${DESCRIPTION}" --user "${USER}" --deploymentType "${DEPLOYMENT_TYPE}"; then
    logInfoMessage "Deployment tracking successful for Entity NAME: ${APM_NAME}, Entity GUID: ${ENTITY_GUID}."
    generateOutput $ACTIVITY_SUB_TASK_CODE true "Deployment tracking successful for Entity NAME: ${APM_NAME}, Entity GUID: ${ENTITY_GUID}."
else
    logErrorMessage "Deployment tracking failed for Entity NAME: ${APM_NAME}, Entity GUID: ${ENTITY_GUID}."
    generateOutput $ACTIVITY_SUB_TASK_CODE false "Deployment tracking failed for Entity NAME: ${APM_NAME}, Entity GUID: ${ENTITY_GUID}."
fi

