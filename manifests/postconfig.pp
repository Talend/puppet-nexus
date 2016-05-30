# === Class: nexus::postconfig
#
# Postconfigure Sonatype Nexus
#
# === Parameters
#
# [*nexus_root*]
#   Nexus root folder
#
# [*admin_password_crypt*]
#   Admin password hash string string
#   See:
#    * https://support.sonatype.com/hc/en-us/articles/213465508-How-can-I-reset-a-forgotten-admin-password-
#    * http://shiro.apache.org/command-line-hasher.html
#
# [*enable_anonymous*]
#
# [*initialize_passwords*]
#
# === Examples
#
# class { 'nexus::postconfig':
#   nexus_root           => '/opt',
#   admin_password_crypt => '$shiro1$SHA-512$1024$G+rxqm4Qw5/J54twR6BrSQ==$2ZUS4aBHbGGZkNzLugcQqhea7uPOXhoY4kugop4r4oSAYlJTyJ9RyZYLuFBmNzDr16Ii1Q+O6Mn1QpyBA1QphA==',
#   enable_anonymous     => false,
#   initialize_passwords => true
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

  $nexus_root           = $nexus::nexus_root,
  $admin_password_crypt = $nexus::admin_password_crypt,
  $enable_anonymous     = $nexus::enable_anonymous,
  $initialize_passwords = $nexus::initialize_passwords,

) {

  validate_string($nexus_root)
  validate_string($admin_password_crypt)
  validate_bool($enable_anonymous)
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
      "set anonymousAccessEnabled/#text ${enable_anonymous}"
    ]
  }

  if $initialize_passwords {
    exec { 'delete user deployment':
      command => '/usr/bin/curl -s -f -X DELETE -u admin:admin123 http://localhost:8081/nexus/service/local/users/deployment',
      onlyif  => '/usr/bin/curl -s -f -X GET    -u admin:admin123 http://localhost:8081/nexus/service/local/users/deployment',
    }

    exec { 'update password for the admin user':
      command => "/usr/bin/curl -X POST -u admin:admin123 http://localhost:8081/nexus/service/local/users_setpw -H 'Content-type: application/xml' -d '<user-changepw><data><oldPassword>admin123</oldPassword><userId>admin</userId><newPassword>${admin_password_crypt}</newPassword></data></user-changepw>'",
      onlyif  => '/usr/bin/curl -s -f -X GET -u admin:admin123 http://localhost:8081/nexus/service/local/users/admin',
    }
  }

}
