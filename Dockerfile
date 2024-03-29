FROM ubuntu:22.04
RUN apt update && apt install -y sudo curl jq vim
RUN curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash
COPY build.sh .
RUN chmod +x build.sh
ADD BP-BASE-SHELL-STEPS .
ENV NEW_RELIC_REGION=""
ENV NEW_RELIC_API_KEY=""
ENV NEW_RELIC_ACCOUNT_ID=""
ENV NEW_RELIC_LICENSE_KEY=""
ENV NEW_RELIC_PROFILE="lenskart"
ENV DEPLOYMENT_TYPE="ROLLING"
ENV SLEEP_DURATION 0s
ENV ACTIVITY_SUB_TASK_CODE NEWRELIC_CHANGE_TRACKER
ENV VALIDATION_FAILURE_ACTION WARNING

ENTRYPOINT [ "./build.sh" ]