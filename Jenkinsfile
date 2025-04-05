pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/Rohsun/my-firstpipeline.git'
        BRANCH = 'main'
        GIT_CREDS = 'github-credentials'
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        IMAGE_NAME = 'rohsun/python-app'
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        DEPLOYMENT_FILE = 'k8s/deployment.yaml'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                git branch: "${env.BRANCH}", url: "${env.GIT_REPO}", credentialsId: "${env.GIT_CREDS}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${env.DOCKERHUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Update K8s Manifest with New Image') {
            steps {
                script {
                    sh """
                        sed -i 's|image: .*|image: ${IMAGE_NAME}:${IMAGE_TAG}|' ${DEPLOYMENT_FILE}
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        git add ${DEPLOYMENT_FILE}
                        git commit -m "Update image to ${IMAGE_NAME}:${IMAGE_TAG}"
                        git push origin ${BRANCH}
                    """
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                    // Replace placeholders with real values
                    sh '''
                        curl -X POST http://<argocd-server>/api/v1/applications/<your-app>/sync \
                            -H "Authorization: Bearer <your-argocd-token>" \
                            -H "Content-Type: application/json"
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up Docker images"
            sh 'docker image prune -af'
        }

        success {
            echo "Pipeline completed successfully ✅"
        }

        failure {
            echo "Pipeline failed ❌. Check the logs above."
        }
    }
}
