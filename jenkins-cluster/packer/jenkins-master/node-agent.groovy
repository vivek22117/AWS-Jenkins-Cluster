import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import hudson.plugins.sshslaves.*

println "--> creating SSH credentials"

domain = Domain.global()
store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

privateKey = new File('/tmp/id_rsa').getText('UTF-8')

slavesPrivateKey = new BasicSSHUserPrivateKey(
CredentialsScope.GLOBAL,
"jenkins-key",
"ec2-user",
new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(privateKey),
"",
""
)


githubCredentials = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  "github", "Github credentials",
  "vivek22117",
  "don@2244"
)


store.addCredentials(domain, slavesPrivateKey)
store.addCredentials(domain, githubCredentials)