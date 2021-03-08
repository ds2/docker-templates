FROM payara/server-full:latest
EXPOSE 4848 8080
VOLUME [ "/libs" ,"${SCRIPT_DIR}/init.d"]

COPY registerJndis.sh ${SCRIPT_DIR}/init.d/
COPY postgresql.jar /libs/
