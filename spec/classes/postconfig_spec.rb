require 'spec_helper'

describe 'nexus::postconfig' do
  let(:default_parameters) {
    {
      'nexus_root'              => '/nexus/root',
      'admin_password_crypt'    => 'some_crypt',
      'enable_anonymous_access' => false,
      'initialize_passwords'    => true
    }
  }

  context 'with default parameters' do
    let(:params) { default_parameters }

    it { should contain_augeas('security-configuration.xml').with(
      'incl' => '/nexus/root/sonatype-work/nexus/conf/security-configuration.xml',
      'lens' => 'Xml.lns',
      'context' => '/files//nexus/root/sonatype-work/nexus/conf/security-configuration.xml/security-configuration',
      'changes' => [
        'rm realms',
        'set realms/realm[last()+1]/#text XmlAuthorizingRealm',
        'set realms/realm[last()+1]/#text XmlAuthenticatingRealm',
        'clear anonymousAccessEnabled',
        'set anonymousAccessEnabled/#text false'
      ]
    ) }

    it { should contain_exec('delete user deployment') }
    it { should contain_exec('update password for the admin user') }
  end

  context 'when initialize_passwords parameter is set to false' do
    let(:params) { default_parameters.merge!( { 'initialize_passwords' => false }) }

    it { should_not contain_exec('delete user deployment') }
    it { should_not contain_exec('update password for the admin user') }
  end

  context 'when enable_anonymous_access is set to true' do
    let(:params) { default_parameters.merge!( { 'enable_anonymous_access' => true }) }

    it { should contain_augeas('security-configuration.xml').with(
      'incl' => '/nexus/root/sonatype-work/nexus/conf/security-configuration.xml',
      'lens' => 'Xml.lns',
      'context' => '/files//nexus/root/sonatype-work/nexus/conf/security-configuration.xml/security-configuration',
      'changes' => [
        'rm realms',
        'set realms/realm[last()+1]/#text XmlAuthorizingRealm',
        'set realms/realm[last()+1]/#text XmlAuthenticatingRealm',
        'clear anonymousAccessEnabled',
        'set anonymousAccessEnabled/#text true'
      ]
    ) }
  end
end
