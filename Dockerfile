# Build stage: Temurin 26 JDK + Maven
FROM eclipse-temurin:26-jdk-noble AS build
WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY pom.xml .
RUN mvn -B -f pom.xml -DskipTests dependency:go-offline

# copy source and build the project
COPY . .
RUN mvn -B -DskipTests package

FROM eclipse-temurin:26-jre-noble
WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

ENV SPRING_PROFILES_ACTIVE=dev
ENV PORT=8091
ENV JAVA_OPTS=""

EXPOSE 8091

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -Dserver.port=${PORT} -jar /app/app.jar"]