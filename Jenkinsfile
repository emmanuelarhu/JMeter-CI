pipeline {
    agent any
    
    parameters {
        choice(
            name: 'TEST_TYPE',
            choices: ['load-test', 'stress-test', 'baseline-test'],
            description: 'Type of performance test to run'
        )
        string(
            name: 'USERS',
            defaultValue: '50',
            description: 'Number of concurrent users'
        )
        string(
            name: 'RAMP_UP',
            defaultValue: '60',
            description: 'Ramp-up time in seconds'
        )
        string(
            name: 'DURATION',
            defaultValue: '300',
            description: 'Test duration in seconds'
        )
    }
    
    environment {
        JMETER_HOME = '/opt/apache-jmeter'
        TIMESTAMP = sh(script: "date +%Y%m%d-%H%M%S", returnStdout: true).trim()
    }
    
    stages {
        stage('Setup') {
            steps {
                echo "Starting ${params.TEST_TYPE} with ${params.USERS} users"
                sh "mkdir -p results"
                sh "${JMETER_HOME}/bin/jmeter --version"
            }
        }
        
        stage('Run Performance Test') {
            steps {
                script {
                    def testName = "${params.TEST_TYPE}-${TIMESTAMP}"
                    
                    sh """
                        ${JMETER_HOME}/bin/jmeter -n \
                        -t test-plans/${params.TEST_TYPE}.jmx \
                        -l results/${testName}.jtl \
                        -j results/${testName}.log \
                        -e -o results/${testName}-report \
                        -Jusers=${params.USERS} \
                        -Jrampup=${params.RAMP_UP} \
                        -Jduration=${params.DURATION} \
                        -q config/test.properties
                    """
                    
                    env.TEST_NAME = testName
                }
            }
        }
        
        stage('Analyze Results') {
            steps {
                script {
                    // Extract key metrics
                    def metrics = sh(
                        script: """
                            awk -F',' 'NR>1 {
                                total++; rt+=\$2; 
                                if(\$8=="true") errors++
                            } END {
                                printf "Total: %d, Avg RT: %.0fms, Errors: %d (%.1f%%)", 
                                total, rt/total, errors, errors/total*100
                            }' results/${env.TEST_NAME}.jtl
                        """,
                        returnStdout: true
                    ).trim()
                    
                    echo "Test Results: ${metrics}"
                }
            }
        }
        
        stage('Performance Gates') {
            steps {
                script {
                    // Simple performance validation
                    sh """
                        # Check if error rate is under 5%
                        ERROR_RATE=\$(awk -F',' 'NR>1 {total++; if(\$8=="true") errors++} END {print errors/total*100}' results/${env.TEST_NAME}.jtl)
                        if (( \$(echo "\$ERROR_RATE > 5" | bc -l) )); then
                            echo "FAIL: Error rate \$ERROR_RATE% exceeds 5%"
                            exit 1
                        fi
                        echo "PASS: Error rate \$ERROR_RATE% is acceptable"
                    """
                }
            }
        }
    }
    
    post {
        always {
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: "results/${env.TEST_NAME}-report",
                reportFiles: 'index.html',
                reportName: 'JMeter Performance Report'
            ])
            
            archiveArtifacts artifacts: 'results/**/*', fingerprint: true
        }
        
        success {
            echo "Performance test completed successfully!"
        }
        
        failure {
            echo "Performance test failed or gates not met"
        }
    }
}