pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials') // Replace with your DockerHub credentials ID
        IMAGE_NAME = 'rohithsun/python-app' // Replace with your image name
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/Rohsun/my-firstpipeline.git'
            }
        }

        stage('Set up Python Environment') {
            steps {
                sh '''
                    echo Creating virtual environment...
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }

