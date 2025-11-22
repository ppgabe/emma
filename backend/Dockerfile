FROM eclipse-temurin:21-jre-alpine

RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY target/*.jar server.jar

ENTRYPOINT ["java", \
  "-XX:+UseSerialGC", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Xss256k", \
  "-jar", "/server.jar"]