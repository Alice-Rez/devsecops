FROM eclipse-temurin:8-jdk
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN groupadd -r pipeline \
 && useradd -r -g pipeline -m -d /home/k8s-pipeline -s /usr/sbin/nologin k8s-pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
USER k8s-pipeline
# ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]
# ENTRYPOINT ["java","-jar","/app.jar"]