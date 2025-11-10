pipeline {
    agent any

    environment {
        TERRAFORM_PATH = 'C:\\terraform\\bin\\terraform.exe'
        AWS_REGION = 'ap-south-1'
    }

    stages {
        stage('Terraform Init') {
            steps {
                echo '🔧 Initializing Terraform...'
                dir('infra') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        bat "${TERRAFORM_PATH} init"
                    }
                }
            }
        }

        stage('Manual Approval - Apply/Destroy') {
            steps {
                script {
                    def userInput = input(
                        id: 'applyDestroyInput',
                        message: '⚙️ Choose Terraform action:',
                        parameters: [
                            choice(
                                name: 'ACTION',
                                choices: ['apply', 'destroy'],
                                description: 'Select whether to apply or destroy the infrastructure'
                            )
                        ]
                    )
                    env.USER_ACTION = userInput
                    echo "✅ User selected: ${userInput}"
                }
            }
        }

        stage('Terraform Apply/Destroy') {
            steps {
                dir('infra') {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                        script {
                            if (env.USER_ACTION == 'apply') {
                                echo '🚀 Applying Terraform configuration...'
                                bat "${TERRAFORM_PATH} apply -auto-approve -var-file=terraform.tfvars"
                            } else {
                                echo '🧹 Destroying Terraform resources...'
                                bat "${TERRAFORM_PATH} destroy -auto-approve -var-file=terraform.tfvars"
                            }
                        }
                    }
                }
            }
        }

        stage('Manual Approval - Start/Stop EC2') {
            steps {
                script {
                    def ec2Action = input(
                        id: 'ec2StartStopInput',
                        message: '💻 Choose EC2 action:',
                        parameters: [
                            choice(
                                name: 'EC2_ACTION',
                                choices: ['start', 'stop'],
                                description: 'Select whether to start or stop EC2 instance'
                            )
                        ]
                    )
                    env.EC2_ACTION = ec2Action
                    echo "✅ User selected EC2 action: ${ec2Action}"
                }
            }
        }

        stage('Start/Stop EC2') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        if (env.EC2_ACTION == 'start') {
                            echo '🟢 Starting EC2 instance...'
                            bat """
                            python scripts/manage_ec2.py start
                            """
                        } else {
                            echo '🔴 Stopping EC2 instance...'
                            bat """
                            python scripts/manage_ec2.py stop
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Please check logs.'
        }
    }
}
