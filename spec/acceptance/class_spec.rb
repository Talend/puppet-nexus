require 'spec_helper_acceptance'

describe 'nexus' do

  context 'with default parameters' do
    it_should_behave_like 'nexus::installed', "
      version  => '2.8.0',
      revision => '05'
    "
    it_should_behave_like 'nexus::running'

    describe file('/srv/sonatype-work/nexus/conf/security-configuration.xml') do
      it { should be_file }
      its(:content) { should include '<anonymousAccessEnabled>false</anonymousAccessEnabled>' }
      its(:content) { should include '<realm>XmlAuthenticatingRealm</realm>' }
      its(:content) { should include '<realm>XmlAuthorizingRealm</realm>' }
    end

    describe 'nexus user deployment should be removed' do
      describe file('/srv/sonatype-work/nexus/conf/security.xml') do
        it { should be_file }
        its(:content) { should_not include '<id>deployment</id>' }
      end
    end
  end

  context 'with download_folder parameter set to /var/tmp' do
    it_should_behave_like 'nexus::installed', "
      version          => '2.8.0',
      revision        =>  '05',
      download_folder =>  '/var/tmp/'
    "
    it_should_behave_like 'nexus::running'

    describe file('/var/tmp/nexus-2.8.0-05-bundle.tar.gz') do
      it { should be_file }
    end
  end

end
