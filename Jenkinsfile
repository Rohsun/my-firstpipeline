pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/Rohsun/my-firstpipeline.git'
        BRANCH = 'main'
        GIT_CREDS = 'github-credentials'
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        IMAGE_NAME = 'rohithsun/python-app'
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        INFRA_REPO = 'https://github.com/Rohsun/k8s-manifests.git'
        INFRA_REPO_DIR = 'k8s-manifests'
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
                dir("${INFRA_REPO_DIR}") {
                    git url: "${INFRA_REPO}", branch: 'main', credentialsId: "${env.GIT_CREDS}"

                    script {
                        sh """
                            sed -i 's|image: .*|image: ${IMAGE_NAME}:${IMAGE_TAG}|' deployment.yaml
                            git config user.email "jenkins@example.com"
                            git config user.name "Jenkins CI"
                            git add deployment.yaml
                            git commit -m "Update image to ${IMAGE_NAME}:${IMAGE_TAG}"
                            git push origin main
                        """
                    }
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                    // Replace with your ArgoCD project/app details
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


