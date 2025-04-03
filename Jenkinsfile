pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials') // Use your stored credential ID
        IMAGE_NAME = "rohsun/my-python-app"
        CONTAINER_NAME = "my-python-app"
    }
    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/Rohsun/my-firstpipeline.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-python-app .'
            }
        }
        stage('Push Image to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-credentials', url: 'https://index.docker.io/v1/']) {
                    sh 'docker tag my-python-app $IMAGE_NAME:latest'
                    sh 'docker push $IMAGE_NAME:latest'
                }
            }
        }
        stage('Deploy Container') {
            steps {
                script {
                    // Stop and remove existing container if running
                    sh '''
                    if [ $(docker ps -q -f name=$CONTAINER_NAME) ]; then
                        docker stop $CONTAINER_NAME
                        docker rm $CONTAINER_NAME
                    fi
                    docker run -d -p 8080:8080 --name $CONTAINER_NAME $IMAGE_NAME:latest
                    '''
                }
            }
        }
    }
}
