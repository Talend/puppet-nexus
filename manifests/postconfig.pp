# === Class: nexus::postconfig
#
# Postconfigure Sonatype Nexus
#
# === Parameters
#
# [*nexus_root*]
#   Nexus root folder
#
# [*admin_password*]
#   Admin password
#
# [*enable_anonymous_access*]
#   If set to true, then anonymous access will be enabled
#
# [*initialize_passwords*]
#   If set to true, then password for the admin user will be updated and the deployment user will be removed
#
# === Examples
#
# class { 'nexus::postconfig':
#   nexus_root              => '/opt',
#   admin_password          => 'ilikerandompasswords',
#   enable_anonymous_access => false,
#   initialize_passwords    => true
# }
#
# === Authors
#
# Andreas Heumaier andreas.heumaier@nordcloud.com
#
# === Copyright
#
# Copyright 2016 Nordcloud
#
class nexus::postconfig(

  $nexus_root              = $nexus::nexus_root,
  $admin_password          = $nexus::admin_password,
  $enable_anonymous_access = $nexus::enable_anonymous_access,
  $initialize_passwords    = $nexus::initialize_passwords,

) {

  validate_string($nexus_root)
  validate_string($admin_password)
  validate_bool($enable_anonymous_access)
  validate_bool($initialize_passwords)

  $security_configuration_file = "${nexus_root}/sonatype-work/nexus/conf/security-configuration.xml"

  augeas { 'security-configuration.xml':
    incl    => $security_configuration_file,
    lens    => 'Xml.lns',
    context => "/files/${security_configuration_file}/security-configuration",
    changes => [
      # enable XML security realms
      'rm realms',
      'set realms/realm[last()+1]/#text XmlAuthorizingRealm',
      'set realms/realm[last()+1]/#text XmlAuthenticatingRealm',
      # update anonymous access
      'clear anonymousAccessEnabled',
      "set anonymousAccessEnabled/#text ${enable_anonymous_access}"
    ]
  }

  if $initialize_passwords {
    exec { 'delete user deployment':
      command => '/usr/bin/curl -s -f -X DELETE -u admin:admin123 http://localhost:8081/nexus/service/local/users/deployment',
      onlyif  => '/usr/bin/curl -s -f -X GET    -u admin:admin123 http://localhost:8081/nexus/service/local/users/deployment',
    }

    exec { 'update password for the admin user':
      command => "/usr/bin/curl -X POST -u admin:admin123 http://localhost:8081/nexus/service/local/users_setpw -H 'Content-type: application/xml' -d '<user-changepw><data><oldPassword>admin123</oldPassword><userId>admin</userId><newPassword>${admin_password}</newPassword></data></user-changepw>'",
      onlyif  => '/usr/bin/curl -s -f -X GET -u admin:admin123 http://localhost:8081/nexus/service/local/users/admin',
    }
  }

}
