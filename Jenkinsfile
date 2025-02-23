pipeline {  
    environment {
      registry = "crsgui/mobead"
      registryCredential = 'DockerHub'
      dockerImage = ''
      developmentImage = ''
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
                    developmentImage = docker.build registry + ":dev"
                }
            }
        }

        stage('SCM Checkout') {
            steps {
                checkout scm
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'criss-sonarqube'

                    withSonarQubeEnv(installationName: 'SonarQubeServer', credentialsId: 'SonarQubePass') {
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=criss-jenkins -Dsonar.sources=. "
                    }
                }
            }
        }

        stage('Remove old development container') {
            steps {
                script {
                    try {
                        sh "docker rm -f " + registry + ":dev"
                    } catch (Exception e) {
                        sh "echo $e"
                    }
                }
            }
        }

        stage ('Deploy into development') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        developmentImage.push()
                    }
                }
            }
        }

        stage('Ask for confirmation to deploy into production') {
            steps {
                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        input(id: "Deploy", message: "Deploy ${BUILD_NUMBER}?", ok: 'Deploy Production Image')
                    }
                }
            }
        }

        stage('Deploy Production Image') {
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