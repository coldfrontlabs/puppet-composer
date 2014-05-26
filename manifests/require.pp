# == Type: composer::project
#
# Installs a given project with composer create-project
#
# === Parameters
#
# Document parameters here.
#
# [*target_dir*]
#   The target dir that composer should be installed to.
#   Defaults to ```/usr/local/bin```.
#
# [*composer_file*]
#   The name of the composer binary, which will reside in ```target_dir```.
#
# [*download_method*]
#   Either ```curl``` or ```wget```.
#
# [*logoutput*]
#   If the output should be logged. Defaults to FALSE.
#
# [*tmp_path*]
#   Where the composer.phar file should be temporarily put.
#
# [*php_package*]
#   The Package name of the PHP CLI package.
#
# [*user*]
#   The user name to exec the composer commands as. Default is undefined.
#
# === Authors
#
# Thomas Ploch <profiploch@gmail.com>
#
# === Copyright
#
# Copyright 2013 Thomas Ploch
#
define composer::require(
  $project_name,
  $target_dir,
  $global                   = false,
  $version                  = undef,
  $prefer_source            = false,
  $prefer_dist              = false,
  $dev                      = false,
  $no_update                = false,
  $no_progress              = false,
  $update_with_dependencies = false,
  $tries                    = 3,
  $timeout                  = 1200,
  $user                     = undef,
) {
  require git
  require composer

  Exec {
    path        => "/bin:/usr/bin/:/sbin:/usr/sbin:${composer::target_dir}",
    environment => "COMPOSER_HOME=${composer::composer_home}",
    user        => $user,
  }

  $glb = $global ? {
    true => 'global',
    default => '',
  }

  $pref_src = $prefer_source? {
    true  => ' --prefer-source',
    false => ''
  }

  $pref_dist = $prefer_dist? {
    true  => ' --prefer-dist',
    false => ''
  }

  $dev_arg = $dev ? {
    true    => ' --dev',
    default => '',
  }

  $nup = $no_update? {
    true  => ' --no-update',
    false => ''
  }

  $nop = $no_progress? {
    true  => ' --no-progress',
    false => ''
  }

  $v = $version? {
    undef   => '',
    default => " ${version}",
  }

  $exec_name    = "composer_require_project_${glb}_${title}"
  $base_command = "${composer::php_bin} ${composer::target_dir}/${composer::composer_file}"
  $end_command  = "${project_name} ${target_dir}"

  exec { $exec_name:
    command => "${base_command}${glb}${pref_src}${pref_dist}${dev_arg}${nup}${nop} require ${end_command}${v}",
    tries   => $tries,
    timeout => $timeout,
    creates => $target_dir,
  }
}
