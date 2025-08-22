# JMeter Performance Testing Project

## Overview
This project contains JMeter performance tests that run in Jenkins CI/CD pipeline.

## Quick Start
1. Update test data in `test-data/` folder
2. Configure properties in `config/` folder  
3. Run locally: `./scripts/run-test.sh`
4. Run in Jenkins: Trigger the pipeline job

## File Structure
- `config/` - Configuration files and properties
- `test-data/` - CSV files with test data
- `test-plans/` - JMeter .jmx test plan files
- `scripts/` - Shell scripts for test execution
- `results/` - Generated test results (ignored by git)

## Test Types
- Load Test: Normal expected traffic
- Stress Test: Beyond normal capacity
- Baseline Test: Single user validation

## Jenkins Integration
The Jenkinsfile defines the CI/CD pipeline that:
- Runs JMeter tests with configurable parameters
- Generates HTML reports
- Archives results
- Validates performance gates