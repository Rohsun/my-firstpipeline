pipeline {
    agent any

    environment {
        IMAGE_NAME = 'rohsun/python-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        FULL_IMAGE = "${IMAGE_NAME}:${IMAGE_TAG}"
        GIT_CREDENTIALS_ID = 'github-credentials'
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

        stage('Run SonarQube Analysis') {
            environment {
                SONAR_SCANNER_HOME = tool 'SonarQubeScanner'
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=python-app \
                        -Dsonar.sources=. \
                        -Dsonar.python.version=3.8
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t $FULL_IMAGE .
                '''
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $FULL_IMAGE
                        docker logout
                    '''
                }
            }
        }

        stage('Update Kubernetes Manifest') {
            steps {
                sh '''
                    echo "Updating manifest with new image tag..."
                    sed -i "s|image:.*|image: $FULL_IMAGE|" k8s/deployment.yaml
                    git config user.email "jenkins@ci.com"
                    git config user.name "Jenkins CI"
                    git add k8s/deployment.yaml
                    git commit -m "Update image tag to $IMAGE_TAG"
                    git push https://$GIT_USER:$GIT_TOKEN@github.com/Rohsun/my-firstpipeline.git HEAD:main
                '''
            }
        }

        stage('Trigger ArgoCD Deployment') {
            steps {
                sh '''
                    echo "Triggering ArgoCD sync..."
                    argocd app sync python-app
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed and deployed to K8s!'
        }
        failure {
            echo '❌ Pipeline failed. Please check the logs.'
        }
    }
}
