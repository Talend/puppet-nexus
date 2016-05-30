require 'spec_helper_acceptance'

shared_examples 'nexus::running' do

  describe user('nexus') do
    it { should belong_to_group 'nexus' }
  end

  describe service('nexus') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  context 'Nexus should be running on the default port' do
    describe command('wget -O - http://localhost:8081/nexus/') do
      its(:stdout) { should match /Sonatype Nexus&trade; 2.8.0-05/ }
    end

    describe port(8081) do
      it { should be_listening }
    end
  end

end
