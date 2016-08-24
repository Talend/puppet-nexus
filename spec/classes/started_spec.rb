require 'spec_helper'

describe 'nexus::started' do
  let(:default_parameters) {
    {
      'nexus_host' => 'nexus_host',
      'nexus_port' => 9999
    }
  }

  context 'with default parameters' do
    let(:params) { default_parameters }

    it { should contain_exec('waiting for Nexus to start').with(
      'command' => "/usr/bin/wget --spider --tries 50 --retry-connrefused http://nexus_host:9999/nexus/"
    ) }
  end
end
