### CLONE IMAGE ###
FROM registry.hub.docker.com/alpine/git:1.0.7 as cloner
WORKDIR /app
RUN git clone https://github.com/gpe-mw-training/rhte2019_ba_lab.git

### BUILDER IMAGE ###
FROM maven:3-jdk-8-slim as builder
COPY --from=cloner /app/rhte2019_ba_lab/hr-hiring/ /build/hr-hiring/
RUN mvn --file build/hr-hiring/pom.xml --batch-mode install -DskipTests

### EXECUTABLE IMAGE ###
FROM registry.redhat.io/rhpam-7/rhpam73-kieserver-openshift
COPY --from=builder /root/.m2/repository /home/jboss/.m2/repository/
COPY cli-cors-config.txt /tmp/cli-cors-config.txt
COPY execute-admin-server.sh /tmp/execute-admin-server.sh
USER root
RUN chown jboss:jboss -R /home/jboss
RUN chmod -R 777 /home/jboss
RUN chmod 644 /tmp/cli-cors-config.txt
RUN chmod 777 /tmp/execute-admin-server.sh
USER jboss
RUN /opt/eap/bin/add-user.sh -a -u 'Bob' -p 'Password1!' -g 'kie-server,interviewer'
RUN /opt/eap/bin/add-user.sh -a -u 'Ann' -p 'Password1!' -g 'kie-server,interviewer'
RUN /opt/eap/bin/add-user.sh -a -u 'Eve' -p 'Password1!' -g 'kie-server,interviewer'
RUN /opt/eap/bin/add-user.sh -a -u 'Tom' -p 'Password1!' -g 'kie-server,talent-acquisition'
RUN /opt/eap/bin/add-user.sh -a -u 'Tina' -p 'Password1!' -g 'kie-server,talent-acquisition'
RUN /opt/eap/bin/add-user.sh -a -u 'Bill' -p 'Password1!' -g 'kie-server,applicant'
RUN /opt/eap/bin/add-user.sh -a -u 'Ava' -p 'Password1!' -g 'kie-server,applicant'
RUN /opt/eap/bin/add-user.sh -a -u 'Super' -p 'Password1!' -g 'kie-server,admin,Administrators'
CMD ["/tmp/execute-admin-server.sh"]

ENV KIE_SERVER_CONTAINER_DEPLOYMENT=hr-hiring=org.acme:hr-hiring:1.0.0