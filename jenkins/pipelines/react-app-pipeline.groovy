// Jenkins Pipeline Configuration for React Application
// This file defines the CI/CD pipeline as code

pipelineJob('react-app-pipeline') {
    displayName('React Application CI/CD Pipeline')
    description('Automated CI/CD pipeline for React application deployment')
    
    // Pipeline configuration
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/your-username/react-app.git')
                        credentials('github-credentials')
                    }
                    branches('*/main', '*/develop')
                    scriptPath('Jenkinsfile')
                }
            }
            lightweight(true)
        }
    }
    
    // Build triggers
    triggers {
        githubPush()
        pollSCM {
            scmpoll_spec('H/5 * * * *')
        }
        cron('H 2 * * 0') // Weekly build on Sunday at 2 AM
    }
    
    // Build parameters
    parameters {
        choiceParam('ENVIRONMENT', ['dev', 'staging', 'prod'], 'Target environment for deployment')
        booleanParam('SKIP_TESTS', false, 'Skip running tests')
        booleanParam('FORCE_DEPLOY', false, 'Force deployment even if tests fail')
        stringParam('DOCKER_TAG', 'latest', 'Docker image tag to deploy')
    }
    
    // Properties
    properties {
        buildDiscarder {
            strategy {
                logRotator {
                    numToKeepStr('20')
                    daysToKeepStr('30')
                    artifactNumToKeepStr('10')
                    artifactDaysToKeepStr('14')
                }
            }
        }
        
        githubProjectProperty {
            projectUrl('https://github.com/your-username/react-app')
        }
        
        pipelineTriggers([
            githubPush(),
            pollSCM('H/5 * * * *')
        ])
    }
    
    // Notifications
    publishers {
        slackNotifier {
            teamDomain('your-team')
            token('slack-token')
            room('#deployments')
            startNotification(true)
            notifySuccess(true)
            notifyAborted(false)
            notifyNotBuilt(false)
            notifyUnstable(true)
            notifyFailure(true)
            notifyBackToNormal(true)
            notifyRepeatedFailure(false)
            includeTestSummary(true)
            commitInfoChoice('AUTHORS_AND_TITLES')
            includeCustomMessage(false)
        }
        
        emailNotification {
            recipients('devops@example.com')
            dontNotifyEveryUnstableBuild(true)
            sendToIndividuals(false)
        }
    }
}

// Multi-branch pipeline for feature branches
multibranchPipelineJob('react-app-multibranch') {
    displayName('React App - Multi-branch Pipeline')
    description('Multi-branch pipeline for React application feature development')
    
    branchSources {
        github {
            id('react-app-github')
            scanCredentialsId('github-credentials')
            repoOwner('your-username')
            repository('react-app')
            
            buildOriginBranch(true)
            buildOriginBranchWithPR(true)
            buildOriginPRMerge(false)
            buildOriginPRHead(true)
            buildForkPRMerge(true)
            buildForkPRHead(false)
        }
    }
    
    // Branch discovery
    configure { node ->
        def traits = node / sources / data / 'jenkins.branch.BranchSource' / source / traits
        traits << 'org.jenkinsci.plugins.github__branch__source.BranchDiscoveryTrait' {
            strategyId(1) // Exclude branches that are also filed as PRs
        }
        traits << 'org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait' {
            strategyId(1) // Merging the pull request with the current target branch revision
        }
        traits << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
            strategyId(1) // Merging the pull request with the current target branch revision
            trust(class: 'org.jenkinsci.plugins.github_branch_source.ForkPullRequestDiscoveryTrait$TrustPermission')
        }
    }
    
    // Orphaned item strategy
    orphanedItemStrategy {
        discardOldItems {
            numToKeep(20)
        }
    }
    
    // Periodic folder computation
    triggers {
        periodicFolderTrigger {
            interval('1d')
        }
    }
}

