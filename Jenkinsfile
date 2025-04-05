pipeline {
    agent any

    environment {
        IMAGE_NAME = 'rohithsun/python-app:latest'
        GIT_CREDENTIALS_ID = 'github-credentials'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        DEPLOYMENT_REPO = 'https://github.com/your-username/k8s-deployments.git' // Replace this
        DEPLOYMENT_BRANCH = 'main'
        MANIFEST_FILE = 'python-app/deployment.yaml' // Path to K8s manifest in the repo
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                git url: 'https://github.com/your-username/python-app.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}")
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                        docker.image("${IMAGE_NAME}").push()
                    }
                }
            }
        }

        stage('Update K8s Manifest with New Image') {
            steps {
                dir('k8s-deployments') {
                    git url: DEPLOYMENT_REPO, branch: DEPLOYMENT_BRANCH, credentialsId: GIT_CREDENTIALS_ID

                    script {
                        // Replace image in deployment YAML
                        sh """
                        sed -i 's|image: .*|image: ${IMAGE_NAME}|' ${MANIFEST_FILE}
                        git config user.name "Jenkins"
                        git config user.email "jenkins@yourdomain.com"
                        git add ${MANIFEST_FILE}
                        git commit -m "Update image to ${IMAGE_NAME}"
                        git push origin ${DEPLOYMENT_BRANCH}
                        """
                    }
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                    // ArgoCD auto-sync will take care of deployment
                    echo 'Assuming ArgoCD is set to auto-sync. No manual sync triggered here.'
                }
            }
        }
    }

    post {
        always {
            sh 'docker image prune -af || true'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}

