ARG BUILD_WEBAPP=0
ARG BUILD_SRC=0
ARG INCLUDE_SRC=0
# Must be `11` if BUILD_WEBAPP is `1`
ARG JAVA_VERSION=11


FROM eclipse-temurin:${JAVA_VERSION}-jdk-jammy AS build
ARG BUILD_WEBAPP
ARG BUILD_SRC
ARG NUTCH_SRC_REPO="https://github.com/apache/nutch.git"
WORKDIR /opt
RUN set -ex; \
    if [ "${BUILD_WEBAPP}" -eq "0" ]; then exit 0; fi; \
    apt-get update; \
    apt-get install --no-install-recommends --no-upgrade -y git maven; \
    apt-get autoremove -y; \
    git clone https://github.com/apache/nutch-webapp.git nutch_webapp; \
    cd nutch_webapp; \
    sed -i 's|<wtp.version>.*</wtp.version>|<wtp.version>2.0</wtp.version>|I' pom.xml; \
    mvn clean install -DskipTests && mvn package;
RUN set -ex; \
    if [ "${BUILD_SRC}" -eq "0" ]; then \
    mkdir -p -m0770 /opt/nutch_source /opt/nutch_runtime/local; \
    exit 0; \
    fi; \
    apt-get update; \
    apt-get install --no-install-recommends --no-upgrade -y git ant; \
    apt-get autoremove -y; \
    git clone ${NUTCH_SRC_REPO} nutch_source; \
    cd nutch_source; \
    ant runtime; \
    cp -r runtime /opt/nutch_runtime; \
    rm -rf build/ runtime/ /root/.ivy2/;


FROM eclipse-temurin:${JAVA_VERSION}-jre-jammy AS base-0
ARG SERVER_PORT=8081
ARG SERVER_HOST=0.0.0.0
ARG CP_NUTCH_RUNTIME="./runtime/local"
ENV VERBOSE="" \
    SERVER_PORT=${SERVER_PORT} \
    SERVER_HOST=${SERVER_HOST} \
    NUTCH_USER="nutch" \
    NUTCH_GROUP="nutch" \
    NUTCH_GID="8081" \
    NUTCH_UID="8081" \
    NUTCH_HOME=/opt/nutch/runtime/local \
    # NUTCH_LOG_DIR=$NUTCH_HOME/logs \
    # NUTCH_LOGFILE=hadoop.log \
    PATH=/opt/nutch/runtime/local/bin:/opt/nutch/runtime/local/docker/scripts:$PATH
RUN set -ex; \
    groupadd -r --gid ${NUTCH_GID} ${NUTCH_GROUP}; \
    useradd -r --uid ${NUTCH_UID} --gid ${NUTCH_GID} ${NUTCH_USER}; \
    mkdir -p -m0770 ${NUTCH_HOME}/crawl; \
    chown -R ${NUTCH_USER}:0 /opt/nutch; \
    chown -R ${NUTCH_USER}:${NUTCH_USER} ${NUTCH_HOME};
VOLUME ${NUTCH_HOME}/crawl
EXPOSE ${SERVER_PORT}
WORKDIR ${NUTCH_HOME}
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nutch-foreground"]


FROM base-0 AS base-1
ARG BUILD_WEBAPP
ENV WEBAPP_PORT=8080
RUN set -ex; \
    if [ "$BUILD_WEBAPP" -eq "0" ]; then exit 0; fi; \
    apt-get update && apt-get install --no-install-recommends --no-upgrade -y maven && apt-get autoremove -y;
COPY --chown=${NUTCH_USER}:0 --from=build /opt/nutch_webapp /opt/nutch_webapp
COPY --chown=${NUTCH_USER}:${NUTCH_USER} --from=build /root/.m2 /home/${NUTCH_USER}/.m2
EXPOSE ${WEBAPP_PORT}
CMD ["start-nutch-webapp"]


FROM base-${BUILD_WEBAPP} AS runtime-0
COPY --chown=${NUTCH_USER}:${NUTCH_USER} --from=build /opt/nutch_runtime/local ${NUTCH_HOME}
COPY --chown=${NUTCH_USER}:0 ${CP_NUTCH_RUNTIME} ${NUTCH_HOME}
COPY --chown=${NUTCH_USER}:0 --chmod=555 ./docker/scripts ${NUTCH_HOME}/docker/scripts
USER $NUTCH_UID


FROM runtime-0 AS runtime-1
COPY --chown=${NUTCH_USER}:0 --from=build /opt/nutch_source /opt/nutch


FROM runtime-${INCLUDE_SRC} AS final
