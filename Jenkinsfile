pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'rohsun/python-app:latest'
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials') // replace with your Jenkins credential ID
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/Rohsun/my-firstpipeline.git', branch: 'main'
            }
        }

        stage('Set up Python Environment') {
            steps {
                sh '''
                    echo "Creating virtual environment..."
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }
