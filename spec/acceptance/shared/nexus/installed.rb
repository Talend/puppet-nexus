require 'spec_helper_acceptance'

shared_examples 'nexus::installed' do |nexus_parameters|

  it 'can be installed with no errors' do
    pp = <<-EOS
    class{ '::java': }

    class{ '::nexus':
      #{nexus_parameters.to_s}
    }
    EOS

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_failures => true)
  end

end
