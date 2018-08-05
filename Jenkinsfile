// Tell Jenkins how to build projects from this repository
pipeline {
  agent {
    label 'iqlabs-performance'
  }

  parameters {
    booleanParam(defaultValue: false, description: 'Set to true if you don\'t want to run the CPS build.', name: 'SKIP_CPS')
    booleanParam(defaultValue: false, description: 'Set to true if you don\'t want to run the benchmark build', name: 'SKIP_BUILD')
    booleanParam(defaultValue: false, description: 'Set to true if you don\'t want to run the benchmark', name: 'SKIP_BENCHMARK')
    string(defaultValue: '1.7.0-SNAPSHOT', description: '', name: 'VIATRA_COMPILER_VERSION')
    string(defaultValue: 'https://build.incquerylabs.com/jenkins/job/VIATRA2-EMF-Core/lastSuccessfulBuild/artifact/releng/org.eclipse.viatra.update/target/repository/', description: 'VIATRA Update site with the benchmarked version.', name: 'VIATRA_REPOSITORY_URL')
    choice(choices: 'ci\nm2m-reduced\nm2m-lowsynch\nm2m\ntoolchain', description: 'Select the benchmark configuration to run (scenarios, cases, tools, etc.)', name: 'BENCHMARK_CONFIG')
    text(defaultValue: 'Measure performance of latest master build', description: 'You may add information on why this benchmark is relevant and include URLs (e.g. Gerrit change including patch version) to ease historical analyis of results.', name: 'BENCHMARK_DESCRIPTION')
  }

  tools {
    maven 'Maven 3.5'
    jdk 'Oracle JDK 8'
  }

  environment {
      MAVEN_OPTS = '-Xmx1024M'
  }

  stages {
    stage('Build CPS') {
      when {
        environment name: 'SKIP_CPS', value: 'false'
      }
      steps {
        sshagent(['24f0908d-7662-4e93-80cc-1143b7f92ff1']) {
          sh "./scripts/update.sh"
        }
        configFileProvider([
            configFile(fileId: 'org.jenkinsci.plugins.configfiles.maven.MavenToolchainsConfig1427876196924', variable: 'TOOLCHAIN'),
            configFile(fileId: 'org.jenkinsci.plugins.configfiles.maven.MavenSettingsConfig1377688925713', variable: 'MAVEN_SETTINGS')]) {
          sh "mvn clean install -f cps-demo/cps/pom.xml -s $MAVEN_SETTINGS -Dviatra.compiler.version=$VIATRA_COMPILER_VERSION -Dviatra.repository.url=$VIATRA_REPOSITORY_URL -Dcps.test.vmargs='-Dgit.clone.location=$WORKSPACE/cps-demo/cps' -Dmaven.repo.local=$WORKSPACE/.repository -B -t $TOOLCHAIN -DskipTests -P !cps.view.gef5"
        }
      }
    }
    stage('Build Benchmark') {
      when {
        environment name: 'SKIP_BUILD', value: 'false'
      }
      steps {
        configFileProvider([
          configFile(fileId: 'org.jenkinsci.plugins.configfiles.maven.MavenToolchainsConfig1427876196924', variable: 'TOOLCHAIN'),
          configFile(fileId: 'org.jenkinsci.plugins.configfiles.maven.MavenSettingsConfig1377688925713', variable: 'MAVEN_SETTINGS')]) {
          sh "mvn clean verify -s $MAVEN_SETTINGS -Dviatra.repository.url=$VIATRA_REPOSITORY_URL -Dcps.test.vmargs='-Dgit.clone.location=$WORKSPACE/cps-demo/cps' -Dmaven.repo.local=$WORKSPACE/.repository -B -t $TOOLCHAIN"
        }
      }
    }
    stage('Run Benchmark') {
      when {
        environment name: 'SKIP_BENCHMARK', value: 'false'
      }
      steps {
        sh "./scripts/benchmark.sh $BENCHMARK_CONFIG"
      }
    }
    stage('Process results') {
      when {
        environment name: 'SKIP_BENCHMARK', value: 'false'
      }
      steps {
        sshagent(['24f0908d-7662-4e93-80cc-1143b7f92ff1']) {
          sh "./scripts/dep-mondo-sam.sh"
          sh "./scripts/store-params.sh"
          sh "./scripts/copy-results.sh $BENCHMARK_CONFIG build$BUILD_NUMBER --push"
        }
      }
    }
    stage('Report') {
      when {
        environment name: 'SKIP_BENCHMARK', value: 'false'
      }
      steps {
        sh "./scripts/report.sh $BENCHMARK_CONFIG"
      }
    }
  }

  post {
    always {
      archiveArtifacts 'releng/com.incquerylabs.examples.cps.rcpapplication.headless.product/target/products/*, benchmark/results/**, benchmark/diagrams/*, benchmark/*'
      junit '**/target/surefire-reports/*.xml'
    }
    success {
      slackSend channel: "viatra-notifications",
        color: "good",
        message: "Config: $BENCHMARK_CONFIG, VIATRA <$VIATRA_REPOSITORY_URL|repository> with $VIATRA_COMPILER_VERSION compiler.\nDescription: $BENCHMARK_DESCRIPTION\n <https://build.incquerylabs.com/jenkins/job/viatra-cps-benchmark/$BUILD_NUMBER/artifact/benchmark/cpsBenchmarkReport.html|View results>",
        teamDomain: "incquerylabs",
        tokenCredentialId: "6ff98023-8c20-4d9c-821a-b769b0ea0fad"
    }
    unstable {
       slackSend channel: "viatra-notifications",
        color: "warning",
        message: "Build Unstable - $JOB_NAME $BUILD_NUMBER (<$BUILD_URL|Open>)",
        teamDomain: "incquerylabs",
        tokenCredentialId: "6ff98023-8c20-4d9c-821a-b769b0ea0fad"
    }
    failure {
      slackSend channel: "viatra-notifications",
        color: "danger",
        message: "Build Failed - $JOB_NAME $BUILD_NUMBER} (<$BUILD_URL|Open>)",
        teamDomain: "incquerylabs",
        tokenCredentialId: "6ff98023-8c20-4d9c-821a-b769b0ea0fad"
    }
  }
}
