# === Class: nexus
#
# Postconfigure Sonatype Nexus
#
# === Parameters
#
# [*version*]
#   The version to download.
#
# [*revision*]
#   The revision of the archive. This is needed for the name of the
#   directory the archive is extracted to.  The default should suffice.
#
# [*nexus_root*]
#   The root directory where the nexus application will live and tarballs
#   will be downloaded to.
#
# === Examples
#
# class{ 'nexus':
#   var => 'foobar'
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
class nexus::postconfig (

  $enable_postconf = true,

){
  if $enable_postconf {

    exec {
      'disable_anonymous':
        command => "/usr/bin/curl -X PUT -u admin:admin123 http://localhost:8081/nexus/service/local/users/anonymous -H 'Content-type: application/json' -d '{\"data\":{\"userId\":\"anonymous\",\"firstName\":\"Nexus\",\"lastName\":\"Anonymous User\",\"email\":\"changeme2@yourcompany.com\",\"status\":\"disabled\",\"roles\":[\"anonymous\",\"repository-any-read\"]}}'",
        onlyif => '/usr/bin/curl -f http://localhost:8081/nexus/service/local/all_repositories';
      'delete_user_deployment':
        command => '/usr/bin/curl -s -f -X DELETE -u admin:admin123 http://localhost:8081/nexus/service/local/users/deployment',
        onlyif => '/usr/bin/curl -s -f -X GET -u admin:admin123 http://localhost:8081/nexus/service/local/users/deployment';
    } 
    exec {"wait for nexus":
      require => Service["nexus"],
      command => "/usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate https://localhost:8081/nexus/",
    }
  }
}