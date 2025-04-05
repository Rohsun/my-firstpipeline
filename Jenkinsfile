pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials') // Jenkins credential ID
        IMAGE_NAME = "rohsun/my-python-app"
        CONTAINER_NAME = "my-python-app"
        APP_PORT = "9090"
        CONTAINER_PORT = "8080"
    }

    tools {
        // Remove 'python' tool block if not configured in Jenkins
        // Python setup will be handled inside the script
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Rohsun/my-firstpipeline.git'
            }
        }

        stage('Set up Python Environment') {
            steps {
                sh '''
                    sudo apt update
                    sudo apt install -y python3-venv python3-pip
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: "$DOCKER_HUB_CREDENTIALS", url: 'https://index.docker.io/v1/']) {
                    sh '''
                        docker tag $IMAGE_NAME $IMAGE_NAME:latest
                        docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    docker stop $CONTAINER_NAME || true
                    docker rm $CONTAINER_NAME || true
                    docker run -d -p $APP_PORT:$CONTAINER_PORT --name $CONTAINER_NAME $IMAGE_NAME:latest
                '''
            }
        }
    }

    post {
        failure {
            echo "Pipeline failed. Check the logs."
        }
        success {
            echo "Deployment successful!"
        }
    }
}
