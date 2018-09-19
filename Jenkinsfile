#!/usr/bin/env groovy

// keep 10 builds history
properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '5']]]);

String project = 'fluentd-journald-elasticsearch'
String imageProject = 'devops'

@Library('ci-shared-libs')
import com.starup.Util as starupUtil

// global settings
String nodeLabel = env.STARUP_NODE_LABEL
String httpProxy = env.STARUP_HTTP_PROXY
String dockerReg = env.STARUP_DOCKER_REGISTRY
String dockerRegCredId = env.STARUP_DOCKER_REGISTRY_CREDID
String imageRepoName = project
String imageFullName = "${starupUtil.getHost(dockerReg)}/${imageProject}/${imageRepoName}"

String imageTag = env.BRANCH_NAME
String imageFullWithTag = "${imageFullName}:${imageTag}"

node(nodeLabel) {
  // get source code to allocated node
  checkout scm

  stage('Build') {
    // build docker image
    def img = dockerBuild(imageFullName,"${httpProxy}")
    //// image basic test
    //img.inside {
      //sh "seems good"
    //}
    // push built image to registry
    docker.withRegistry(dockerReg, dockerRegCredId) {
      img.push(imageTag)
    }
  }
}
