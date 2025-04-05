pipeline {
    agent any
    environment {
        IMAGE_NAME = "rohsun/my-python-app"
        CONTAINER_NAME = "my-python-app"
        SONAR_PROJECT_KEY = "my-python-app"
        SONAR_SCANNER_HOME = tool 'SonarQubeScanner' // Make sure you configure this tool in Jenkins
    }
    tools {
        python 'Python3' // Jenkins Python tool (configure under Global Tools)
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Rohsun/my-firstpipeline.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Run Tests') {
            steps {
                // Adjust the command based on your test setup
                sh 'pytest tests/'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONARQUBE_ENV = credentials('sonarqube-token') // Store SonarQube token as Jenkins credential
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                    ${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONARQUBE_ENV
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-credentials', url: 'https://index.docker.io/v1/']) {
                    sh """
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                    docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                    docker push ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh """
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true
                docker run -d -p 9090:8080 --name ${CONTAINER_NAME} ${IMAGE_NAME}:${BUILD_NUMBER}
                """
            }
        }

        /*
        stage('Update Kubernetes Manifest and Trigger ArgoCD') {
            steps {
                sh '''
                sed -i "s|image:.*|image: ${IMAGE_NAME}:${BUILD_NUMBER}|" k8s/deployment.yaml
                git config --global user.email "jenkins@ci.com"
                git config --global user.name "Jenkins"
                git add k8s/deployment.yaml
                git commit -m "Updated image version to ${IMAGE_NAME}:${BUILD_NUMBER}"
                git push origin main
                '''
                sh 'argocd app sync my-python-app'
            }
        }
        */
    }
    post {
        failure {
            echo 'Build Failed!'
        }
        success {
            echo "Application successfully deployed at http://<your-ec2-ip>:9090"
        }
    }
}

