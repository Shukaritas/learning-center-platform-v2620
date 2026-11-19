pipeline {
  agent any

  tools {
    maven 'MAVEN_3_9'
    jdk 'JDK_26'
  }

  environment {
    REGISTRY_USER = "shukaritas"
    IMAGE_NAME    = "learning-center-platform-u202313403"
    TAG           = "${env.BUILD_NUMBER}"
  }

  stages {
    stage('Compile') {
      steps {
        withMaven(maven: 'MAVEN_3_9') {
          sh 'mvn clean compile'
        }
      }
    }
    stage('SonarQube Analisis') {
      steps {
        withMaven(maven: 'MAVEN_3_9') {
          withSonarQubeEnv('Jenkins-Webhook') {
            sh 'mvn clean verify sonar:sonar'
          }
        }
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Docker Image') {
      steps {
        withMaven(maven: 'MAVEN_3_9') {
          sh 'mvn package -DskipTests'
        }
        withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            echo "Iniciando sesión en Docker Hub..."
            sh "echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin"

            echo "Construyendo y publicando imagen..."
            sh "docker buildx build --platform linux/amd64 -t ${REGISTRY_USER}/${IMAGE_NAME}:${TAG} -t ${REGISTRY_USER}/${IMAGE_NAME}:latest --push ."
          }
        }
      }
    }
  }
}