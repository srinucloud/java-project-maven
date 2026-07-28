pipeline {

    agent { label 'node1' }

    tools {
            jdk 'jdk21'
            maven 'maven'
   }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/srinucloud/java-project-maven.git'
            }
        }

        stage('Build & Unit Test') {
            steps {
                sh 'mvn clean verify'
                junit 'target/surefire-reports/*.xml'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONARQUBE_SCANNER_HOME = tool 'sonar-scanner'
            }

            steps {
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

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deploy Artifact to Nexus') {
            steps {
                withMaven(
                    globalMavenSettingsConfig: 'settings.xml',
                    jdk: 'jdk21',
                    maven: 'maven'
                ) {
                    sh 'mvn deploy'
                }

                archiveArtifacts artifacts: 'target/*.war'
            }
        }

        stage('Docker Build') {
            steps {
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
            steps {
                sh '''
                    trivy image \
                    --format table \
                    -o trivy-image-report.txt \
                    srinu0930/netflixproject:latest
                '''
                archiveArtifacts artifacts: 'trivy-image-report.txt'
            }
        }
    }
}
