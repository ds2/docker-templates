FROM postgres:13-alpine
ARG logsDir=/db-logs
ARG dataDir=/db-data
ARG POSTGRES_JAR_URL=https://search.maven.org/remotecontent?filepath=org/postgresql/postgresql/42.2.19/postgresql-42.2.19.jar
ARG LQ_CLIENT_URL=https://github.com/liquibase/liquibase/releases/download/v4.3.2/liquibase-4.3.2.tar.gz
ARG libsDir=/db-libs
ARG lqBinDir=/usr/local/apps/lq
ARG pgConfDir=/pg-confs
ENV LOGS_DIR=${logsDir}
ENV DATA_DIR=${dataDir}
ENV LQ_CTXS="notset"
ENV LQ_BIN_DIR=${lqBinDir}
ENV LQ_SLEEP=5
ENV PG_CONFS_DIR=${pgConfDir}
ENV LANG de_DE.utf8
ENV LQ_SH_DIR=/lq-scripts

RUN whoami
RUN apk update; apk add curl gzip tar openjdk8-jre
COPY liquibase.sh ${LQ_SH_DIR}/90-lqbase.sh
COPY copyPgConfs.sh ${LQ_SH_DIR}/91-copyConfigs.sh
COPY entrypoint.sh /lq-entrypoint.sh
RUN mkdir -p ${LOGS_DIR} ${DATA_DIR} ${libsDir} ${lqBinDir} ${PG_CONFS_DIR}; chmod 777 ${LOGS_DIR} ${DATA_DIR} ${libsDir} ${PG_CONFS_DIR}
RUN curl -o ${libsDir}/postgresql.jar -L ${POSTGRES_JAR_URL}; curl -o ${libsDir}/lq.tgz -L ${LQ_CLIENT_URL}
RUN cd ${lqBinDir}; tar -xzvf ${libsDir}/lq.tgz
RUN cp /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh; cp /lq-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
# USER postgres
