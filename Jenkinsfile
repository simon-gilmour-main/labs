pipeline {
  agent any

  options {
    timestamps()
  }

  parameters {
    choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action')
    string(name: 'ALLOWED_CIDR', defaultValue: 'YOUR_PUBLIC_IP/32', description: 'Your laptop public IP in CIDR format')
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
              -var-file=dev.tfvars \
              -var="allowed_cidr=${ALLOWED_CIDR}" \
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
            terraform destroy -auto-approve \
              -var-file=dev.tfvars \
              -var="allowed_cidr=${ALLOWED_CIDR}"
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
