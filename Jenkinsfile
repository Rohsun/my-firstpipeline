pipeline {
    agent any

    environment {
        IMAGE_NAME = "my-python-app"
        DOCKER_HUB_USER = "rohsun"  // Change this to your DockerHub username
        REPO_URL = "https://github.com/Rohsun/my-firstpipeline.git"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: REPO_URL
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                script {
                    // Ensure DockerHub credentials are stored in Jenkins as 'dockerhub-credentials'
                    withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                        sh "docker tag ${IMAGE_NAME} ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    sh "docker run -d -p 8080:8080 --name ${IMAGE_NAME} ${DOCKER_HUB_USER}/${IMAGE_NAME}:latest"
                }
            }
        }
    }
}
