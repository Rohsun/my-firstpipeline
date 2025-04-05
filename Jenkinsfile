pipeline {
    agent any

    environment {
        IMAGE_NAME = "rohsun/my-python-app"
        CONTAINER_NAME = "my-python-app"
        APP_PORT = "9090"
        CONTAINER_PORT = "8080"
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
                    echo "Installing Python dependencies"
                    apt-get update && apt-get install -y python3-venv python3-pip
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag $IMAGE_NAME $IMAGE_NAME:latest
                        docker push $IMAGE_NAME:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    echo "Stopping old container if exists..."
                    docker stop $CONTAINER_NAME || true
                    docker rm $CONTAINER_NAME || true

                    echo "Running new container..."
                    docker run -d -p $APP_PORT:$CONTAINER_PORT --name $CONTAINER_NAME $IMAGE_NAME:latest
                '''
            }
        }
    }

    post {
        success {
            echo '🎉 Deployment successful!'
        }
        failure {
            echo '💥 Pipeline failed. Check the logs!'
        }
    }
}

