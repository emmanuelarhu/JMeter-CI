pipeline {
	agent {
		label 'linux-agent'
    }

    stages {
		stage('Checkout') {
			steps {
				git branch: 'main', url: 'https://github.com/emmanuelarhu/JMeter-CI.git'
            }
        }

        stage('Run JMeter Test') {
			steps {
				// Clean old reports if any exists
                sh 'rm -rf reports results.jtl || true'

                // Run JMeter in non-GUI mode
                sh '''
                jmeter -n -t HTTP(S) Test Script Recorder.jmx \
                       -l results.jtl \
                       -e -o reports
                '''
            }
        }

        stage('Publish Report') {
			steps {
				publishHTML(target: [
                    allowMissing: false,
                    keepAll: true,
                    reportDir: 'reports',
                    reportFiles: 'index.html',
                    reportName: 'JMeter HTML Report'
                ])
            }
        }
    }

    post {
		always {
			archiveArtifacts artifacts: 'results.jtl, reports/**', fingerprint: true
        }
    }
}






