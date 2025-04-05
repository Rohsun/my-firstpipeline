pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials') // ID in Jenkins credentials
        DOCKER_IMAGE = "rohsun/python-app"
        VERSION = "v68" // You can dynamically generate this from Git commit/tag/time
        LATEST_TAG = "latest"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Checkout Source Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-credentials',
                    url: 'https://github.com/Rohsun/my-firstpipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t $DOCKER_IMAGE:$VERSION .
                        docker tag $DOCKER_IMAGE:$VERSION $DOCKER_IMAGE:$LATEST_TAG
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh """
                            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                            docker push $DOCKER_IMAGE:$VERSION
                            docker push $DOCKER_IMAGE:$LATEST_TAG || echo 'Skipping push for latest tag if not found.'
                        """
                    }
                }
            }
        }

        stage('Update K8s Manifest with New Image') {
            steps {
                script {
                    sh """
                        sed -i 's|image: .*|image: $DOCKER_IMAGE:$VERSION|' k8s/deployment.yaml
                        git config --global user.email "jenkins@yourdomain.com"
                        git config --global user.name "Jenkins"
                        git add k8s/deployment.yaml
                        git commit -m "Update image to $VERSION"
                        git push origin main
                    """
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                    // Replace with your ArgoCD CLI/API sync command if using automation
                    sh 'echo "Triggering ArgoCD sync..."'
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up Docker images"
            sh 'docker image prune -af || true'
        }
        failure {
            echo "Pipeline failed ❌. Check the logs above."
        }
    }
}
