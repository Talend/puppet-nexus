# === Class: nexus::package
#
# Install the Nexus package
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
# class{ 'nexus::package': }
#
# === Authors
#
# Tom McLaughlin <tmclaughlin@hubspot.com>
#
# === Copyright
#
# Copyright 2013 Hubspot
#
class nexus::package (
  $version = $::nexus::version,
  $revision = $::nexus::revision,
  $deploy_pro = $::nexus::deploy_pro,
  $download_site = $::nexus::download_site,
  $nexus_root = $::nexus::nexus_root,
  $nexus_home_dir = $::nexus::nexus_home_dir,
  $nexus_user = $::nexus::nexus_user,
  $nexus_group = $::nexus::nexus_group,
  $nexus_work_dir = $::nexus::nexus_work_dir,
  $nexus_work_dir_manage = $::nexus::nexus_work_dir_manage,
  $nexus_work_recurse = $::nexus::nexus_work_recurse,
  $nexus_selinux_ignore_defaults = $::nexus::nexus_selinux_ignore_defaults,
  $download_folder = $::nexus::download_folder,
) {

  $nexus_home      = "${nexus_root}/${nexus_home_dir}"

  $full_version = "${version}-${revision}"

  if ($deploy_pro) {
    $bundle_type = '-professional'
  } else {
    $bundle_type = ''
  }

  $nexus_archive   = "nexus${bundle_type}-${full_version}-bundle.tar.gz"
  $download_url    = "${download_site}/${nexus_archive}"
  $dl_file         = "${download_folder}/${nexus_archive}"
  $nexus_home_real = "${nexus_root}/nexus${bundle_type}-${full_version}"

  # NOTE: When setting version to 'latest' the site redirects to the latest
  # release. But, nexus-latest-bundle.tar.gz will already exist and
  # therefore the exec will never be triggered.  In reality 'latest' will
  # lock you to a version.
  #
  # NOTE:  I *think* this won't repeatedly download the file because it's
  # linked to an exec resource which won't be realized if a directory
  # already exists.
  wget::fetch{ $nexus_archive:
    source      => $download_url,
    destination => $dl_file,
    before      => Exec['nexus-untar'],
  }

  exec{ 'nexus-untar':
    command => "tar zxf ${download_folder}/${nexus_archive} --directory ${nexus_root}",
    creates => $nexus_home_real,
    path    => ['/bin','/usr/bin'],
  }

  # NOTE: $nexus_work_dir in later releases was moved to a directory not
  # under the application.  This is why we do not make recursing optional
  # for this resource but do for $nexus_work_dir.
  exec { "Nexus chown ${nexus_home_real}":
    path        => ['/bin','/usr/bin'],
    command     => "chown -R ${nexus_user}:${nexus_group} ${nexus_home_real}",
    subscribe   => Exec[ 'nexus-untar'],
    refreshonly => true,
    timeout     => 0,
  }

  # I have an EBS volume for $nexus_work_dir and mounting code in our tree
  # creates this and results in a duplicate resource. -tmclaughlin
  if $nexus_work_dir_manage == true {
    $nexus_work_dir_chown_flag_file = "${nexus_root}/puppet_nexus_work_managed_dir_chown.flag"
    exec { "Nexus chown ${nexus_work_dir}":
      path    => ['/bin','/usr/bin'],
      command => "chown -R ${nexus_user}:${nexus_group} ${nexus_work_dir} && touch ${nexus_work_dir_chown_flag_file}",
      creates => $nexus_work_dir_chown_flag_file,
      require => Exec[ 'nexus-untar'],
      timeout => 0,
    }
  }

  file{ $nexus_home:
    ensure  => link,
    target  => $nexus_home_real,
    require => Exec['nexus-untar']
  }
}
