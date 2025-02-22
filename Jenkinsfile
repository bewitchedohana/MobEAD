pipeline {  
    environment {
      registry = "crsgui/mobead"
      registryCredential = 'DockerHub'
      dockerImage = ''
    }

    agent any

    stages { 
        stage('Lint Dockerfile'){
            steps{
                echo "Pipeline Usando Jenkinsfile"
                sh 'docker run --rm -i hadolint/hadolint < Dockerfile'
            }
        }
        stage('Build image') {
            steps{
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
                }
            }
        }

        stage('Ask for confirmation') {
            steps {
                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        input(id: "Deploy", message: "Deploy ${BUILD_NUMBER}?", ok: 'Deploy Image')
                    }
                }
            }
        }

        stage('Deploy Image') {
            steps {
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                    }
                }
            }
        }
    } 
}