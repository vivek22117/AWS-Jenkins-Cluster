#!/bin/bash

sudo systemctl start docker

JENKINS_URL="${jenkins_url}"
JENKINS_USERNAME="${jenkins_username}"
JENKINS_PASSWORD="${jenkins_password}"
ENV="${environment}"
TOKEN=$(curl -u $JENKINS_USERNAME:$JENKINS_PASSWORD ''$JENKINS_URL'/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,":",//crumb)')
INSTANCE_HOST=$(curl -s 169.254.169.254/latest/meta-data/local-hostname)
INSTANCE_IP=$(curl -s 169.254.169.254/latest/meta-data/local-ipv4)
JENKINS_CREDENTIALS_ID="${jenkins_credentials_id}"

sleep 60

curl -v -u $JENKINS_USERNAME:$JENKINS_PASSWORD -H "$TOKEN" -d 'script=
import hudson.model.Slave
import hudson.plugins.sshslaves.SSHLauncher
import hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy
import hudson.slaves.ComputerLauncher
import hudson.slaves.DumbSlave
import hudson.slaves.RetentionStrategy

ComputerLauncher launcher = new SSHLauncher("'$INSTANCE_IP'", 22,
        "'$JENKINS_CREDENTIALS_ID'","", null, null, "", 60, 3, 15,
         new NonVerifyingKeyVerificationStrategy())

Slave slave = new DumbSlave("'$INSTANCE_IP'-'$ENV'", "/home/ec2-user", launcher)

slave.nodeDescription = "Jenkins slave for dev environment"
slave.numExecutors = 2
slave.labelString = "'$ENV'"
slave.mode = Node.Mode.NORMAL
slave.retentionStrategy = new RetentionStrategy.Always()
Jenkins.instance.addNode(slave)
' $JENKINS_URL/script