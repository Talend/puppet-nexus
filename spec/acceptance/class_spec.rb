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

  context 'when admin_password_crypt parameter set' do
    it_should_behave_like 'nexus::installed', "
      version              => '2.8.0',
      revision             =>  '05',
      initialize_passwords =>  true,
      admin_password_crypt =>  'the_crypt'
    "
    it_should_behave_like 'nexus::running'

    describe 'admin user should have its password updated' do
      describe file('/srv/sonatype-work/nexus/conf/security.xml') do
        it { should be_file }
        its(:content) { should_not include '<password>the_crypt</password>' }
      end
    end
  end

end
