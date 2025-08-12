FROM eclipse-temurin:8-jdk
EXPOSE 8080
ARG JAR_FILE=target/*.jar
ARG APP_UID=10001
ARG APP_GID=10001
RUN groupadd -g ${APP_GID} pipeline \
 && useradd -u ${APP_UID} -g ${APP_GID} -m -d /home/k8s-pipeline -s /usr/sbin/nologin k8s-pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
USER k8s-pipeline
# ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]
# ENTRYPOINT ["java","-jar","/app.jar"]