#!/usr/bin/env bash

HOSTNAME=`hostname -s`
OS=`uname -s`
LOG=
JENKINS_URL=""
JOB_NAME=""
USER=""
PASS=""
#
jenkins_url_opt(){
  if [ `echo ${JENKINS_URL}| grep https` ];then
    URL_OPTS="-k -H "Expect:" -X POST -d @${TEMP}"
  else
    URL_OPTS="-X POST -d @${TEMP}"
  fi
}
#
jenkins_notification(){
  TEMP=$(mktemp -t notify_jenkins.XXXXXXXX)
  echo "<run><log encoding=\"hexBinary\">$(hexdump -v -e '1/1 "%02x"' $LOG)</log><result>${RESULT}</result><duration>${ELAPSED_MS}</duration></run>" > ${TEMP}
  if [ -n "${USER}" ];then
    curl ${URL_OPTS} -u ${USER}:${PASS} ${JENKINS_URL}/job/${JOB_NAME}/postBuildResult
  else
    curl ${URL_OPTS} ${JENKINS_URL}/job/${JOB_NAME}/postBuildResult
  fi
  rm ${TEMP}
  rm ${LOG}
}
#
start_time(){
  if [ ${OS} = "Linux" ];then
    START_TIME=$(date +%s.%N) 
  else
    START_TIME=$(date +%s)
  fi
}
#
end_time(){
  if [ ${OS} = "Linux" ];then
    END_TIME=$(date +%s.%N) 
  else
    END_TIME=$(date +%s)
  fi
  ELAPSED_MS=$(echo "($END_TIME - $START_TIME) * 1000 / 1" | bc)
  echo "Start time: $START_TIME" >> ${LOG}
  echo "End time:   $END_TIME" >> ${LOG}
  echo "Elapsed ms: $ELAPSED_MS" >> ${LOG}
}
