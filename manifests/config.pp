# === Class: nexus::config
#
# Configure nexus.
#
# === Parameters
#
# NONE
#
# === Examples
#
# class{ 'nexus::config': }
#
# === Authors
#
# Tom McLaughlin <tmclaughlin@hubspot.com>
#
# === Copyright
#
# Copyright 2013 Hubspot
#
class nexus::config(
  $nexus_root = $::nexus::nexus_root,
  $nexus_home_dir = $::nexus::nexus_home_dir,
  $nexus_host = $::nexus::nexus_host,
  $nexus_port = $::nexus::nexus_port,
  $nexus_context = $::nexus::nexus_context,
  $nexus_work_dir = $::nexus::nexus_work_dir,

  $java_initmemory      = 128,
  $java_maxmemory       = 256,
  $install_java         = true,
  $admin_password_crypt = '$shiro1$SHA-512$1024$G+rxqm4Qw5/J54twR6BrSQ==$2ZUS4aBHbGGZkNzLugcQqhea7uPOXhoY4kugop4r4oSAYlJTyJ9RyZYLuFBmNzDr16Ii1Q+O6Mn1QpyBA1QphA==',
  $enable_anonymous     = false,
  $initialize_passwords = true,

) {

  $nexus_properties_file = "${nexus_root}/${nexus_home_dir}/conf/nexus.properties"

  # Add systemd suport
  if $::lsbmajdistrelease == "7" {
    file{'/usr/lib/systemd/system/nexus.service':
      ensure  => 'present',
      content => template('nexus/nexus.service.erb')
    }
  }

  ini_setting {
    'java_initmemory':
      ensure  => present,
      path    => "${nexus_root}/nexus/bin/jsw/conf/wrapper.conf",
      section => '',
      setting => 'wrapper.java.initmemory',
      value   => $java_initmemory,
      notify  => Service['nexus'];

    'java_maxmemory':
      ensure  => present,
      path    => "${nexus_root}/nexus/bin/jsw/conf/wrapper.conf",
      section => '',
      setting => 'wrapper.java.maxmemory',
      value   => $java_maxmemory,
      notify  => Service['nexus'];
  }



  file_line{ 'nexus-application-host':
    path  => $nexus_properties_file,
    match => '^application-host',
    line  => "application-host=${nexus_host}"
  }

  file_line{ 'nexus-application-port':
    path  => $nexus_properties_file,
    match => '^application-port',
    line  => "application-port=${nexus_port}"
  }

  file_line{ 'nexus-webapp-context-path':
    path  => $nexus_properties_file,
    match => '^nexus-webapp-context-path',
    line  => "nexus-webapp-context-path=${nexus_context}"
  }

  file_line{ 'nexus-work':
    path  => $nexus_properties_file,
    match => '^nexus-work',
    line  => "nexus-work=${nexus_work_dir}"
  }
}
