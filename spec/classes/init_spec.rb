require 'spec_helper'

describe 'nexus' do
  let(:params) {
    {
      'version' => '2.11.2'
    }
  }

  context 'no params set' do
    let(:params) {{}}

    it 'should fail if no version configured' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
             /Cannot set version nexus version to "latest" or leave undefined./)
    end
  end

  context 'with a version set' do
    it { should compile }

    it { should contain_class('nexus') }
    it { should contain_class('nexus::params') }

    it { should contain_package('wget') }

    it { should contain_group('nexus').with(
      'ensure' => 'present',
    ) }

    it { should contain_user('nexus').with(
      'ensure'  => 'present',
      'comment' => 'Nexus User',
      'gid'     => 'nexus',
      'home'    => '/srv',
      'shell'   => '/bin/sh',
      'system'  => true,
      'require' => 'Group[nexus]',
    ) }

    it { should contain_anchor('nexus::begin') }
    it { should contain_class('nexus::package').that_requires(
      'Anchor[nexus::begin]' ) }
    it { should contain_class('nexus::config').that_requires(
      'Class[nexus::package]' ).that_notifies('Class[nexus::service]') }
    it { should contain_class('nexus::service').that_subscribes_to(
      'Class[nexus::config]' ) }
    it { should contain_class('nexus::started').that_requires('Class[nexus::service]') }
    it { should contain_class('nexus::postconfig').that_requires(
        'Class[nexus::service]' ) }
    it { should contain_anchor('nexus::end').that_requires(
      'Class[nexus::service]' ) }

    it 'should handle deploy_pro' do
      params.merge!(
        {
          'deploy_pro' => true,
        }
      )

      should create_class('nexus::package').with(
        'deploy_pro'    => true,
        'download_site' => 'http://download.sonatype.com/nexus/professional-bundle',
      )
    end

    it 'should not have a user or group if nexus_manage_user is false' do
      params.merge!(
        {
          'nexus_manage_user' => false,
        }
      )

      should_not contain_group('nexus')
      should_not contain_user('nexus')
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :
