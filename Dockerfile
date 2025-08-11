FROM eclipse-temurin:8-jdk
EXPOSE 8080
ARG JAR_FILE=target/*.jar
# RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
# COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
# USER k8s-pipeline
ADD ${JAR_FILE} app.jar
# ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]
ENTRYPOINT ["java","-jar","/app.jar"]