FROM tomcat:8-jre8
ARG OPENAM_KEYSTORE_PASSWORD=AP@55word
ARG OPENAM_VERSION
ENV OPENAM_VERSION ${OPENAM_VERSION:-13.5.0}
ENV CATALINA_OPTS="-Xmx2048m -server"
RUN apt-get update && \
    apt-get install -y zip net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    addgroup --gid 1001 openam && \
    adduser --system --home "/home/openam" --shell /bin/bash --uid 1001 --ingroup openam  --disabled-password openam && \
    mkdir -p /openam /home/openam/conf /home/openam/admintools && \
    chown openam:openam -R /openam /usr/local/tomcat /home/openam

ADD bin/* /bin/
RUN chmod +x /bin/*.sh

RUN openssl req -new -newkey rsa:2048 -nodes -out /opt/server.csr -keyout /opt/server.key -subj "/C=US/ST=SanFrancisco/L=SanFrancisco/O=SierraCedar SE/OU=Technology/CN=openam.example.com" \
        && openssl x509 -req -days 365 -in /opt/server.csr -signkey /opt/server.key -out /opt/server.crt \
        && openssl pkcs12 -export -in /opt/server.crt -inkey /opt/server.key -out /opt/server.p12 -name tomcat -password pass:${OPENAM_KEYSTORE_PASSWORD} \
       && keytool -importkeystore -deststorepass ${OPENAM_KEYSTORE_PASSWORD} -destkeypass ${OPENAM_KEYSTORE_PASSWORD} -destkeystore /opt/server.keystore -srckeystore /opt/server.p12 -srcstoretype PKCS12 -srcstorepass ${OPENAM_KEYSTORE_PASSWORD} -alias tomcat

USER openam

ADD tools/openam.war $CATALINA_HOME/webapps

ADD tools/SSOConfiguratorTools-13.5.0.zip /home/openam
ADD tools/SSOAdminTools-13.5.0.zip /home/openam
RUN unzip $CATALINA_HOME/webapps/openam.war  -d  $CATALINA_HOME/webapps/openam && \
    unzip /home/openam/SSOAdminTools-${OPENAM_VERSION}.zip -d /home/openam/admintools && \
    unzip /home/openam/SSOConfiguratorTools-${OPENAM_VERSION}.zip -d /home/openam/conf && \
    touch /usr/local/tomcat/webapps/ROOT/version && \
    echo ${OPENAM_VERSION} | cut -d '.' -f 1 > /usr/local/tomcat/webapps/ROOT/version

# add SSL to server.xml  and upload to the server
#ADD configs/server.xml ${CATALINA_HOME}/conf/
# Add CORS to web.xml
#ADD configs/web.xml ${CATALINA_HOME}/conf/
#RUN sed -i "s/KEYSTORE_PASSWORD_PLACEHOLDER/${OPENAM_KEYSTORE_PASSWORD}/g" ${CATALINA_HOME}/conf/server.xml

EXPOSE 8080
EXPOSE 8443
CMD ["/bin/run_me.sh"]
