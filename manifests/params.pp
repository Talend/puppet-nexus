# === Class: nexus::params
#
# module parameters.
#
# === Parameters
#
# NONE
#
# === Examples
#
# class nexus inherits nexus::params {
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
class nexus::params {
  # See nexus::package on why this won't increment the package version.
  $version                       = 'latest'
  $revision                      = '01'
  $deploy_pro                    = false
  $download_site                 = 'http://download.sonatype.com/nexus/oss'
  $nexus_root                    = '/srv'
  $nexus_home_dir                = 'nexus'
  $nexus_work_recurse            = true
  $nexus_work_dir_manage         = true
  $nexus_selinux_ignore_defaults = true
  $nexus_user                    = 'nexus'
  $nexus_group                   = 'nexus'
  $nexus_host                    = '0.0.0.0'
  $nexus_port                    = '8081'
  $nexus_context                 = '/nexus'
  $nexus_manage_user             = true
  $pro_download_site             = 'http://download.sonatype.com/nexus/professional-bundle'
  $download_folder               = '/srv'
  $java_initmemory               = 128
  $java_maxmemory                = 256
  $install_java                  = true
  $admin_password_crypt          = '$shiro1$SHA-512$1024$G+rxqm4Qw5/J54twR6BrSQ==$2ZUS4aBHbGGZkNzLugcQqhea7uPOXhoY4kugop4r4oSAYlJTyJ9RyZYLuFBmNzDr16Ii1Q+O6Mn1QpyBA1QphA=='
  $enable_anonymous              = false
  $initialize_passwords          = true
}
