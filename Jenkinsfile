pipeline {

    agent none

    stages {

        stage('Git Checkout') {
            agent { label 'node1' }

            steps {
                git branch: 'main',
                    url: 'https://github.com/srinucloud/java-project-maven.git'
            }
        }

        stage('Build & Unit Test') {
            agent {
                label 'node1'
            }

            tools {
                jdk 'jdk21'
                maven 'maven'
            }

            steps {
                sh 'mvn clean verify'

                junit 'target/surefire-reports/*.xml'

                stash name: 'source', includes: '**/*'
            }
        }

        stage('SonarQube Analysis') {
            agent {
                label 'node1'
            }

            environment {
                SONARQUBE_SCANNER_HOME = tool 'sonar-scanner'
            }

            steps {

                unstash 'source'

                withSonarQubeEnv('sonar-server') {

                    sh """
                    ${SONARQUBE_SCANNER_HOME}/bin/sonar-scanner \
                    -Dsonar.projectKey=netflix \
                    -Dsonar.projectName=netflix \
                    -Dsonar.sources=src \
                    -Dsonar.java.binaries=target/classes \
                    -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                    """

                }
            }
        }

        // stage('Quality Gate') {
        //     agent none

        //     steps {
        //         timeout(time: 1, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: false
        //         }
        //     }
        // }

        stage('Deploy Artifact to Nexus') {
            agent {
                label 'node1'
            }

            tools {
                jdk 'jdk21'
                maven 'maven'
            }

            steps {

                unstash 'source'

                withMaven(
                    globalMavenSettingsConfig: 'settings.xml',
                    jdk: 'jdk21',
                    maven: 'maven'
                ) {
                    sh 'mvn deploy'
                }

                archiveArtifacts artifacts: 'target/*.war',
                                 fingerprint: false
            }
        }
        
        stage('Docker Build') {
            agent {
                label 'node2'
            }
            steps {
                unstash 'source'
                withDockerRegistry(credentialsId: 'docker-creds', url: 'https://index.docker.io/v1/') {
                    sh '''
                        docker build -t netflixproject:${BUILD_NUMBER} .
                        docker tag netflixproject:${BUILD_NUMBER} srinu0930/netflixproject:latest
                        docker push srinu0930/netflixproject:latest
                    '''
                    
                }

            }
        }

        stage('Trivy Image Scan') {
    agent { label 'node1' }

    steps {
        sh '''
            trivy image \
            --format table \
            -o trivy-image-report.txt \
            srinu0930/netflixproject:latest
        '''

        // archiveArtifacts artifacts: 'trivy-image-report.txt'
    }
}
    }
}
