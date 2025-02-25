pipeline {  
    environment {
      registry = "crsgui/mobead"
      registryCredential = 'DockerHub'
      dockerImage = ''
      productionImageName = 'mobead_image_production'
      devImageName = 'mobead_image_development'
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

        stage ('Push image') {
            steps {
                script {
                    docker.withRegistry('', registryCredential) {
                        dockerImage.push()
                    }
                }
            }
        }
        
        stage('Run development image') {
            steps {
                script {
                    try {
                        sh "docker rm -f ${devImageName}"
                    } catch (Exception e) {
                        sh "echo $e";
                    }
                }

                script {
                    sh "docker run -d -p 3001:80 --name=${devImageName} " + registry + ":$BUILD_NUMBER"
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
                    try {
                        sh "docker rm -f ${productionImageName}"
                    } catch(Exception e) {
                        sh "echo $e"
                    }
                }

                script {
                    sh "docker run -d -p 3000:80 --name=${productionImageName} " + registry + ":$BUILD_NUMBER"
                }
            }
        }
    } 
}