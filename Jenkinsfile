/* https://jenkins.io/doc/book/pipeline/
 * https://wilsonmar.github.io/jenkins2-pipeline/
 * https://getintodevops.com/blog/building-your-first-docker-image-with-jenkins-2-guide-for-developers
 * https://zwischenzugs.com/2017/04/23/things-i-wish-i-knew-before-using-jenkins-pipelines/
 * https://github.com/jenkinsci/pipeline-examples/tree/master/pipeline-examples
 * https://automatingguy.com/2017/12/29/jenkins-pipelines-shared-libraries/
 * https://wiki.jenkins.io/display/JENKINS/SCM+Filter+Branch+PR+Plugin
 */

import hudson.model.Job
import jenkins.scm.api.mixin.ChangeRequestSCMHead
import jenkins.scm.api.mixin.TagSCMHead
import org.jenkinsci.plugins.workflow.multibranch.BranchJobProperty
import groovy.json.JsonSlurper

try {

  node('jenkins-builder') {
    properties([disableConcurrentBuilds()])

    def JOB_NAME_PARTS = JOB_NAME.tokenize('/') as String[]
    def PIPELINE_NAME = JOB_NAME_PARTS[0]

    ws("${HOME}/workspace/${PIPELINE_NAME}/${env.BRANCH_NAME}") {
      dir("${HOME}/workspace/${PIPELINE_NAME}/${env.BRANCH_NAME}/") {

        def isPRBuild = {
          return isPRBuildExt(currentBuild.rawBuild.parent)
        }

        def isTagBuild = {
          return isTagBuildExt(currentBuild.rawBuild.parent)
        }

        stage('Checkout Source Code') {
          checkout scm
          sh(returnStdout: true, script: "/usr/bin/git show --pretty=format: --name-only")
        }

        stage('Echo Variables') {
          echo "JOB_NAME: ${env.JOB_NAME}"
          echo "BUILD_ID: ${env.BUILD_ID}"
          echo "BUILD_NUMBER: ${env.BUILD_NUMBER}"
          echo "BRANCH_NAME: ${env.BRANCH_NAME}"
          echo "PULL_REQUEST: ${env.CHANGE_ID}"
          echo "BUILD_NUMBER: ${env.BUILD_NUMBER}"
          echo "BUILD_URL: ${env.BUILD_URL}"
          echo "NODE_NAME: ${env.NODE_NAME}"
          echo "BUILD_TAG: ${env.BUILD_TAG}"
          echo "JENKINS_URL: ${env.JENKINS_URL}"
          echo "EXECUTOR_NUMBER: ${env.EXECUTOR_NUMBER}"
          echo "WORKSPACE: ${env.WORKSPACE}"
          echo "GIT_COMMIT: ${env.GIT_COMMIT}"
          echo "GIT_URL: ${env.GIT_URL}"
          echo "GIT_BRANCH: ${env.GIT_BRANCH}"
          LAST_COMMIT_MSG = sh(returnStdout: true, script: "/usr/bin/git log -n 1 --pretty=format:'%s'")
          echo "LAST_COMMIT_MSG: ${LAST_COMMIT_MSG}"
          echo sh(script: 'env|sort', returnStdout: true)
          sh('echo $(hostname)')
        }

        stage("Is Build a Branch, Tag or PR?"){
          if(isPRBuild()) {
            echo "This is a PR Build"
          }
          if(isTagBuild()) {
            echo "This is a Tag Build"
          }
          if(!isPRBuild() && !isTagBuild()) {
            echo "This is a normal Branch"
          }
        }

        stage('Terminate VM?') {
          script {
            def terminate_vm_userInput = input(id: 'terminate_vm_userInput', message: 'Terminate VM?',
              parameters: [[$class: 'ChoiceParameterDefinition', defaultValue: 'strDef',
              description:'describing choices', name:'nameChoice', choices: "No\nYes"]
            ])

            env.terminate_vm = terminate_vm_userInput
            echo "TERMINATE_VM: ${env.terminate_vm}"
          }

          if (env.terminate_vm == 'Yes') {
            sh """
              echo \$(hostname)
              pwd
              echo "sudo -H -u jenkins fqdn=${fqdn} vagrant destroy \$fqdn --force"
              sudo -H -u jenkins fqdn=${fqdn} vagrant destroy \$fqdn --force
              echo "sudo -H -u jenkins vagrant global-status"
              sudo -H -u jenkins vagrant global-status
            """
          }
          else if (env.terminate_vm == 'No') {
            sh """
              echo \$(hostname)
              pwd
              echo "cd ${env.WORKSPACE}; sudo -H -u jenkins fqdn=${fqdn} vagrant destroy \$fqdn"
              sudo -H -u jenkins vagrant global-status
            """
          }
        }

        stage('Which Operating System?') {
          script {
            def os_vm_userInput = input(id: 'os_vm_userInput', message: 'Which Operating System?',
              parameters: [[$class: 'ChoiceParameterDefinition', defaultValue: 'strDef',
              description:'describing choices', name:'nameChoice', choices: "debian\nubuntu"]
            ])

            env.os_vm = os_vm_userInput
            echo "OS_VM: ${env.os_vm}"
          }
        }

        stage('Update Vagrant box') {
          sh('echo $(hostname)')
          sh('vagrant box update')
          sh('vagrant box prune --force')
        }

        stage('Provision Vagrant') {
          sh('echo $(hostname)')
          sh('pwd')
          sh """
            fqdn=${env.fqdn}
            echo \$fqdn
            os_vm=${env.os_vm}
            echo \$os_vm
          """
          sh('env | grep fqdn')
          sh('fqdn=${fqdn} vagrant up \$fqdn --provision')
          sh('fqdn=${fqdn} vagrant ssh \$fqdn -c "hostname; netstat -nlp; ps aux"')
        }

        stage('Test Vagrant') {
          sh """
            echo \$(hostname)
            pwd
            fqdn=${fqdn} vagrant status \$fqdn
          """
          sh('fqdn=${fqdn} vagrant ssh \$fqdn -c "hostname; netstat -nlp; ps aux"')
        }

        stage('Terminate VM?') {
          script {
            def terminate_vm_userInput = input(id: 'terminate_vm_userInput', message: 'Terminate VM?',
              parameters: [[$class: 'ChoiceParameterDefinition', defaultValue: 'strDef',
              description:'describing choices', name:'nameChoice', choices: "Yes\nNo"]
            ])

            env.terminate_vm = terminate_vm_userInput
            echo "TERMINATE_VM: ${env.terminate_vm}"
          }

          if (env.terminate_vm == 'Yes') {
            sh """
              echo \$(hostname)
              pwd
              echo "sudo -H -u jenkins fqdn=${fqdn} vagrant destroy \$fqdn --force"
              sudo -H -u jenkins fqdn=${fqdn} vagrant destroy \$fqdn --force
              echo "sudo -H -u jenkins vagrant global-status"
              sudo -H -u jenkins vagrant global-status
            """
          }
          else if (env.terminate_vm == 'No') {
            sh """
              echo \$(hostname)
              pwd
              echo "cd ${env.WORKSPACE}; sudo -H -u jenkins fqdn=${fqdn} vagrant destroy \$fqdn"
              sudo -H -u jenkins vagrant global-status
            """
          }
        }

        stage('Proceed to?') {
          script {
            def userInput = input(id: 'userInput', message: 'Proceed to?',
              parameters: [[$class: 'ChoiceParameterDefinition', defaultValue: 'strDef',
              description:'describing choices', name:'nameChoice', choices: "Mobile\nQA\nUAT\nDevelopment\nStaging\nProduction\nMaster"]
            ])

            env.proceed_to = userInput
            echo "PROCEED_TO: ${env.proceed_to}"
          }
          sh 'printenv'
          echo sh(script: 'env|sort', returnStdout: true)
        }

        stage("Deploying") {
          echo "PROCEED_TO: ${env.proceed_to}"
        }

        stage('Provision Docker') {
          if(env.BRANCH_NAME == 'master'){
            node('master') {
              sh('echo $(hostname)')
              app = docker.build("devops", "--build-arg FQDN=devops-${short_commit}.example .")
            }
          } else {
            node('master') {
              sh('echo $(hostname)')
              app = docker.build("devops", "--build-arg FQDN=devops-${short_commit}.example .")
            }
          }
        }

        stage('Run Docker') {
          if(env.BRANCH_NAME == 'master'){
            node('master') {
              sh('echo $(hostname)')
              app = docker.image("devops").run("--interactive=true --tty=true --privileged -it")
              sh('docker ps')
              sh('docker images')
            }
          } else {
            node('master') {
              sh('echo $(hostname)')
              app = docker.image("devops").run("--interactive=true --tty=true --privileged -it")
              sh('docker ps')
              sh('docker images')
            }
          }
        }

        stage('Test Docker') {
          if(env.BRANCH_NAME == 'master'){
            node('master') {
              sh('echo $(hostname)')
              sh('docker ps')
              sh('docker images')
            }
          } else {
            node('master') {
              sh('echo $(hostname)')
              sh('docker ps')
              sh('docker images')
            }
          }
        }

        stage('Push image') {
          if(env.BRANCH_NAME == 'master'){
            node('master') {
              sh('echo $(hostname)')
              docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                app.push("latest")
              }
            }
          } else {
            node('master') {
              sh('echo $(hostname)')
              docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                app.push("latest")
              }
            }
          }
        }
      }
    }

  } // node
  notifyBuild('SUCCESSFUL')
} // try end
catch (exc) {
  notifyBuild('ERROR')
}

// Helper Functions
@NonCPS
def isPRBuildExt(Job build_parent) {
  build_parent.getProperty(BranchJobProperty).branch.head in ChangeRequestSCMHead
}

@NonCPS
def isTagBuildExt(Job build_parent) {
  build_parent.getProperty(BranchJobProperty).branch.head in TagSCMHead
}

// https://mfarache.github.io/mfarache/Chatops-Slack-Jenkins-integration/
def notifyBuild(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${LAST_COMMIT_MSG}"
  def summary = "${subject} ${env.BUILD_URL}"

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  slackSend (color: colorCode, message: summary)
}
