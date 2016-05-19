require 'puppetlabs_spec_helper/module_spec_helper'

describe 'nexus::params' do

  context 'with default params' do
    it { should contain_class('nexus::params') }
  end
end

# vim: sw=2 ts=2 sts=2 et :
