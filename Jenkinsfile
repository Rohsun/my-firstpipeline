pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials') // Jenkins credentials ID
        IMAGE_NAME = 'rohithsun/python-app' // Your DockerHub repo
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
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withDockerRegistry([ credentialsId: "$DOCKERHUB_CREDENTIALS", url: '' ]) {
                    sh 'docker push $IMAGE_NAME:latest'
                }
            }
        }

        stage('Update Kubernetes Manifest') {
            steps {
                sh '''
                    sed -i "s|image:.*|image: $IMAGE_NAME:latest|g" k8s/deployment.yaml
                    git config --global user.email "jenkins@example.com"
                    git config --global user.name "jenkins"
                    git commit -am "Update image tag to latest"
                    git push origin main
                '''
            }
        }

        stage('Trigger ArgoCD Deployment') {
            steps {
                sh '''
                    curl -X POST http://argocd-server/api/v1/applications/my-app/sync \
                    -H "Authorization: Bearer <ARGOCD_TOKEN>"
                '''
            }
        }
    }

    post {
        failure {
            echo '❌ Pipeline failed. Please check the logs.'
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
    }
}
