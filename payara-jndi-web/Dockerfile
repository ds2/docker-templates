FROM payara/server-web:6.2024.6-jdk17
USER root
ENV JEE_LIBS_DIR /libs
ENV JEE_CONFIGS_DIR /configs
ENV JEE_LOGS_DIR /jee-logs
RUN apt-get update; apt-get upgrade -y; apt-get install -y curl
RUN mkdir ${JEE_LIBS_DIR}; chmod 777 ${JEE_LIBS_DIR}; chown payara ${JEE_LIBS_DIR}
RUN mkdir ${JEE_CONFIGS_DIR}; chmod 777 ${JEE_CONFIGS_DIR}; chown payara ${JEE_CONFIGS_DIR}
RUN mkdir ${JEE_LOGS_DIR}; chmod 777 ${JEE_LOGS_DIR}; chown payara ${JEE_LOGS_DIR}
RUN apt-get autoremove --purge; apt-get clean

USER payara
COPY logging.properties ${JEE_CONFIGS_DIR}/
COPY registerJndis.sh ${SCRIPT_DIR}/init.d/
COPY preconfigure.sh ${SCRIPT_DIR}/init.d/
COPY dl.sh ${JEE_LIBS_DIR}/dl.sh
RUN cd ${JEE_LIBS_DIR}; ./dl.sh
