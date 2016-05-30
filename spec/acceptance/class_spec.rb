require 'spec_helper_acceptance'

describe 'nexus' do

  context 'with default parameters' do
    it_should_behave_like 'nexus::installed', "
      version  => '2.8.0',
      revision => '05'
    "
    it_should_behave_like 'nexus::running'

    describe 'xml realms should be enabled' do
      describe file('/srv/sonatype-work/nexus/conf/security-configuration.xml') do
        it { should be_file }
        its(:content) { should include '<realm>XmlAuthenticatingRealm</realm>' }
        its(:content) { should include '<realm>XmlAuthorizingRealm</realm>' }
      end
    end

    describe 'anonymous access should be disabled' do
      describe file('/srv/sonatype-work/nexus/conf/security-configuration.xml') do
        it { should be_file }
        its(:content) { should include '<anonymousAccessEnabled>false</anonymousAccessEnabled>' }
      end
    end

    describe 'nexus user deployment should be removed' do
      describe file('/srv/sonatype-work/nexus/conf/security.xml') do
        it { should be_file }
        its(:content) { should_not include '<id>deployment</id>' }
      end
    end
  end

  context 'when download_folder parameter set to /var/tmp' do
    it_should_behave_like 'nexus::installed', "
      version         => '2.8.0',
      revision        =>  '05',
      download_folder =>  '/var/tmp/'
    "
    it_should_behave_like 'nexus::running'

    describe file('/var/tmp/nexus-2.8.0-05-bundle.tar.gz') do
      it { should be_file }
    end
  end

  context 'when admin_password parameter set' do
    it_should_behave_like 'nexus::installed', "
      version              => '2.8.0',
      revision             =>  '05',
      initialize_passwords =>  true,
      admin_password       =>  'randompassword'
    "
    it_should_behave_like 'nexus::running'

    describe 'admin user should have its password updated' do
      describe file('/srv/sonatype-work/nexus/conf/security.xml') do
        it { should be_file }
        its(:content) { should_not include '<password>$shiro1$SHA-512$1024$YqRBSFRnZDcVwUUag81I1Q==$Wzce7Ab03rDz3/ThvMzzx39lntW/+Ds2h1PioyC9FQ/rspeFwPu57kYD2jw2qFlMq8GhOps0K29ZCA72a+eJ+g==</password>' } # randompassword hash string
      end

      describe command('/usr/bin/curl -v -f -X GET -u admin:randompassword http://localhost:8081/nexus/service/local/users/admin') do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should include 'HTTP/1.1 200 OK' }
        its(:stdout) { should include '<userId>admin</userId>' }
      end
    end
  end

end
