pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy', 'start', 'stop'], description: 'Choose what to do')
    }

    environment {
        TF_VAR_FILE        = "terraform-ap-south-1.tfvars"
        TERRAFORM_DIR      = "."
        AWS_DEFAULT_REGION = "ap-south-1"
        TERRAFORM_EXE      = "C:\\terraform\\bin\\terraform.exe"
    }

    // Use one valid cron trigger only (no comments allowed)
    triggers {
        cron('30 4 * * 1-5\n0 18 * * 1-5')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git credentialsId: 'private-key-jenkins',
                    url: 'git@github.com:danish0410/create_ec2instance_startandstop.git',
                    branch: 'feature'
            }
        }

        stage('Terraform Init') {
            when { expression { params.ACTION == 'apply' || params.ACTION == 'destroy' } }
            steps {
                dir(env.TERRAFORM_DIR) {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-creds']]) {
                        bat "${env.TERRAFORM_EXE} init"
                    }
                }
            }
        }

        stage('Terraform Apply/Destroy') {
            when { expression { params.ACTION == 'apply' || params.ACTION == 'destroy' } }
            steps {
                script {
                    def cmd = (params.ACTION == 'apply') ? "apply" : "destroy"
                    bat """
                        ${env.TERRAFORM_EXE} ${cmd} ^
                            -var-file=${env.TF_VAR_FILE} ^
                            -auto-approve
                    """
                }
            }
        }

        stage('Start/Stop EC2') {
            when { expression { params.ACTION == 'start' || params.ACTION == 'stop' } }
            steps {
                withAWS(credentials: 'aws-jenkins-creds', region: env.AWS_DEFAULT_REGION) {
                    script {
                        def instanceId = 'i-0908cb5ba8973ecc9'
                        if (params.ACTION == 'start') {
                            echo "🚀 Starting EC2 instance: ${instanceId}"
                            sh "aws ec2 start-instances --instance-ids ${instanceId} --region ${env.AWS_DEFAULT_REGION}"
                        } else {
                            echo "🛑 Stopping EC2 instance: ${instanceId}"
                            sh "aws ec2 stop-instances --instance-ids ${instanceId} --region ${env.AWS_DEFAULT_REGION}"
                        }
                    }
                }
            }
        }
    }

    post {
        success { echo "✅ ${params.ACTION} completed successfully." }
        failure { echo "❌ ${params.ACTION} failed." }
    }
}
