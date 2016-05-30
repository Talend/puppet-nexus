# === Class: nexus
#
# Install and configure Sonatype Nexus
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
# Tom McLaughlin <tmclaughlin@hubspot.com>
#
# === Copyright
#
# Copyright 2013 Hubspot
#
class nexus (
  $version               = $nexus::params::version,
  $revision              = $nexus::params::revision,
  $deploy_pro            = $nexus::params::deploy_pro,
  $download_site         = $nexus::params::download_site,
  $nexus_root            = $nexus::params::nexus_root,
  $nexus_home_dir        = $nexus::params::nexus_home_dir,
  $nexus_work_dir        = undef,
  $nexus_work_dir_manage = $nexus::params::nexus_work_dir_manage,
  $nexus_user            = $nexus::params::nexus_user,
  $nexus_group           = $nexus::params::nexus_group,
  $nexus_host            = $nexus::params::nexus_host,
  $nexus_port            = $nexus::params::nexus_port,
  $nexus_work_recurse    = $nexus::params::nexus_work_recurse,
  $nexus_context         = $nexus::params::nexus_context,
  $nexus_manage_user     = $nexus::params::nexus_manage_user,
  $download_folder       = $nexus::params::download_folder,
  $java_initmemory         = $nexus::params::java_initmemory,
  $java_maxmemory          = $nexus::params::java_maxmemory,
  $install_java            = $nexus::params::install_java,
  $admin_password_crypt    = $nexus::params::admin_password_crypt,
  $enable_anonymous_access = $nexus::params::enable_anonymous_access,
  $initialize_passwords    = $nexus::params::initialize_passwords,

) inherits nexus::params {

  include stdlib

  ensure_packages(['wget'])

  # Bail if $version is not set.  Hopefully we can one day use 'latest'.
  if ($version == 'latest') or ($version == undef) {
    fail('Cannot set version nexus version to "latest" or leave undefined.')
  }

  if $nexus_work_dir != undef {
    $real_nexus_work_dir = $nexus_work_dir
  } else {
    $real_nexus_work_dir = "${nexus_root}/sonatype-work/nexus"
  }

  # Determine if Nexus Pro should be deployed instead of OSS
  validate_bool($deploy_pro)
  if ($deploy_pro) {
    if ( $download_site != $nexus::params::download_site) {
      # Use any download site that was passed in
      $real_download_site = $download_site
    } else {
      # No download site was specifically defined, the default is
      # incorrect for pro so switch to the correct one
      $real_download_site = $nexus::params::pro_download_site
    }
  } else {
    # Deploy OSS version. The default download_site, or whatever is
    # passed in is the correct location to download from
    $real_download_site = $download_site
  }

  anchor{ 'nexus::begin': }
  anchor{ 'nexus::end': }

  if($nexus_manage_user){
    group { $nexus_group :
      ensure  => present
    }

    user { $nexus_user:
      ensure  => present,
      comment => 'Nexus User',
      gid     => $nexus_group,
      home    => $nexus_root,
      shell   => '/bin/sh', # required to start application via script.
      system  => true,
      require => Group[$nexus_group]
    }
  }

  class{ 'nexus::package':
    version               => $version,
    revision              => $revision,
    deploy_pro            => $deploy_pro,
    download_site         => $real_download_site,
    nexus_root            => $nexus_root,
    nexus_home_dir        => $nexus_home_dir,
    nexus_user            => $nexus_user,
    nexus_group           => $nexus_group,
    nexus_work_dir        => $real_nexus_work_dir,
    nexus_work_dir_manage => $nexus_work_dir_manage,
    nexus_work_recurse    => $nexus_work_recurse,
    notify                => Class['nexus::service']
  }

  class{ 'nexus::config':
    nexus_root     => $nexus_root,
    nexus_home_dir => $nexus_home_dir,
    nexus_host     => $nexus_host,
    nexus_port     => $nexus_port,
    nexus_context  => $nexus_context,
    nexus_work_dir => $real_nexus_work_dir,
    notify         => Class['nexus::service']
  }

  class { 'nexus::service':
    nexus_home => "${nexus_root}/${nexus_home_dir}",
    nexus_user => $nexus_user,
    version    => $version,
  }

  class { 'nexus::started':
    nexus_host => $nexus_host,
    nexus_port => $nexus_port
  }

  class { 'nexus::postconfig':
    nexus_root              => $nexus_root,
    admin_password_crypt    => $admin_password_crypt,
    enable_anonymous_access => $enable_anonymous_access,
    initialize_passwords    => $initialize_passwords
  }

  Anchor['nexus::begin'] ->
    Class['nexus::package'] ->
    Class['nexus::config'] ->
    Class['nexus::service'] ->
    Class['nexus::started'] ->
    Class['nexus::postconfig'] ->
  Anchor['nexus::end']
}
