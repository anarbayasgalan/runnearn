# Build configuration
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY earn/pom.xml .
COPY earn/src ./src
# Build the application
RUN mvn clean package -DskipTests

# Run configuration
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
