pipeline {
  agent any

  options {
    timestamps()
  }

  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action')
  }

  environment {
    TF_IN_AUTOMATION = 'true'
    AWS_DEFAULT_REGION = 'eu-west-2'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir('infra-demo/terraform') {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Validate') {
      steps {
        dir('infra-demo/terraform') {
          sh 'terraform validate'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir('infra-demo/terraform') {
          sh '''
            terraform plan \
              -out=tfplan
          '''
        }
      }
    }

    stage('Approval') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        input message: 'Apply this Terraform plan?'
      }
    }

    stage('Terraform Apply') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        dir('infra-demo/terraform') {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }

    stage('Terraform Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        dir('infra-demo/terraform') {
          sh '''
            terraform destroy -auto-approve"
          '''
        }
      }
    }

    stage('Show Outputs') {
      when {
        expression { params.ACTION == 'apply' }
      }
      steps {
        dir('infra-demo/terraform') {
          sh 'terraform output'
        }
      }
    }
  }
}
