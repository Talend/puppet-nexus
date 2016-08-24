# === Class: nexus::started
#
# Waiting till the Nexus is started
#
# === Parameters
#
# [*nexus_host*]
#   Nexus hostname or IP
# [*nexus_port*]
#   Nexus port number
#
# === Examples
#
# class { 'nexus::started': }
#
# === Authors
#
# Talend <agrigoriev@talend.com>
#
# === Copyright
#
# Copyright 2016 Talend SA
#
class nexus::started (

  $nexus_host = $nexus::nexus_host,
  $nexus_port = $nexus::nexus_port

) {

  validate_string($nexus_host)
  validate_integer($nexus_port)

  exec { 'waiting for Nexus to start':
    command => "/usr/bin/wget --spider --tries 50 --retry-connrefused http://${nexus_host}:${nexus_port}/nexus/"
  }

}
