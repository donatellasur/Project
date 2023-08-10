pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                // Checkout the source code from Git
                checkout scm
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t gcr.io/clever-oasis-395212/website_image /var/jenkins_home/workspace/websitePipeline/wildrydes-site/'
            }
        }
        
        stage('Push') {
            steps {
                //  Tag the Docker image with GCR URL
                //  sh 'docker tag website_image gcr.io/clever-oasis-395212/website_image'

                //  Push the image to GCR
                sh 'docker push gcr.io/clever-oasis-395212/website_image'
            }
        }

        stage('Deploy'){
            steps{
                //Deploy with Kubernetes
                sh 'kubectl apply -f /var/jenkins_home/workspace/websitePipeline/Kubernetes/deployment.yaml'
                sh 'kubectl apply -f /var/jenkins_home/workspace/websitePipeline/Kubernetes/service.yaml'
                sh 'kubectl apply -f /var/jenkins_home/workspace/websitePipeline/Kubernetes/autoscale.yaml'
            }
        }

        stage('Hello') {
            steps {
                echo 'Hello, Jenkins!'
            }
        }

        stage('Unit Test') {
            steps {
                script {
                    def logFilePath = "${JENKINS_HOME}/jobs/${JOB_NAME}/builds/${currentBuild.number}/log"
                    def logContent = readFile file: logFilePath
                    if (logContent.contains('Hello, Jenkins!')) {
                        echo 'Test passed: "Hello, Jenkins!" message found.'
                    } else {
                        error 'Test failed: "Hello, Jenkins!" message not found.'
                    }
                }
            }
        }
       
    }
}