# syntax=docker/dockerfile:1.2

# Build stage
FROM maven:3.8.3-openjdk-17 AS build
WORKDIR /app
COPY . .
# Use cache for Maven dependencies
RUN --mount=type=cache,target=/root/.m2 mvn clean package

# Runtime stage
FROM openjdk:17-alpine
WORKDIR /app
#ENV JAVA_OPTS="-Xms128m -Xmx512m"
COPY --from=build /app/target/*.jar /app/app.jar
#ENTRYPOINT ["java","-jar"]
CMD ["sh","-c","java -jar /app/app.jar"]

