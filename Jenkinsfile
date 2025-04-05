pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials') // Your DockerHub Jenkins credential ID
        IMAGE_NAME = "rohsun/my-python-app"
        CONTAINER_NAME = "my-python-app"
        GIT_USERNAME = "your-username"         // GitHub username with push access to manifest repo
        GIT_EMAIL = "you@example.com"          // Your Git email
        MANIFEST_REPO = "https://github.com/your-username/k8s-manifests.git"
        BRANCH_NAME = "main"
    }

    stages {
        stage('Clone App Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Rohsun/my-firstpipeline.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh '''
                    python3 -m venv venv
                    source venv/bin/activate
                    pip install -r requirements.txt
                    python3 -m unittest discover tests
                '''
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-credentials', url: 'https://index.docker.io/v1/']) {
                    sh '''
                        docker tag $IMAGE_NAME:latest $IMAGE_NAME:latest
                        docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Update K8s Deployment Manifest') {
            steps {
                sh '''
                    rm -rf temp-manifests
                    git clone $MANIFEST_REPO temp-manifests
                    cd temp-manifests

                    git config user.email "$GIT_EMAIL"
                    git config user.name "$GIT_USERNAME"

                    # Update image in deployment file
                    sed -i "s|image: .*$|image: $IMAGE_NAME:latest|" deployment.yaml

                    git add deployment.yaml
                    git commit -m "Update image to $IMAGE_NAME:latest"
                    git push origin $BRANCH_NAME
                '''
            }
        }
    }

    post {
        failure {
            mail to: 'your@email.com',
                 subject: "Jenkins Job Failed: ${env.JOB_NAME}",
                 body: "Job ${env.JOB_NAME} [${env.BUILD_NUMBER}] failed. Check Jenkins for details."
        }
        success {
            echo 'Pipeline completed successfully!'
        }
    }
}
