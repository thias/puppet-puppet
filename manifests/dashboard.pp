# Class: puppet::dashboard
#
# This is a work in progress. There are still manual steps involved :
#
#     cd /usr/share/puppet-dashboard/
#     rake RAILS_ENV=production db:create
#     rake RAILS_ENV=production db:migrate
#     rake RAILS_ENV=production cert:create_key_pair
#     rake RAILS_ENV=production cert:request
#     (sign)
#     rake RAILS_ENV=production cert:retrieve
#     chgrp puppet-dashboard certs/dashboard.private_key.pem
#
class puppet::dashboard (
  $database_database                   = 'dashboard',
  $database_username,
  $database_password,
  $database_encoding                   = 'utf8',
  $database_adapter                    = 'mysql',
  $settings_enable_inventory_service   = 'false',
  $settings_use_file_bucket_diffs      = 'false',
  $settings_no_longer_reporting_cutoff = '3600',
  $settings_enable_read_only_mode      = 'false',
  $reports_prune_upto_days             = '30',
) {

  package { 'puppet-dashboard': ensure => installed }

  service { [ 'puppet-dashboard', 'puppet-dashboard-workers' ]:
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
  }

  file { '/usr/share/puppet-dashboard/config/database.yml':
    content => template("${module_name}/dashboard/database.yml.erb"),
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    mode    => '0640',
    require => Package['puppet-dashboard'],
    notify  => [
      Service['puppet-dashboard'],
      Service['puppet-dashboard-workers'],
    ],
  }
  file { '/usr/share/puppet-dashboard/config/settings.yml':
    content => template("${module_name}/dashboard/settings.yml.erb"),
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    mode    => '0644',
    require => Package['puppet-dashboard'],
    notify  => [
      Service['puppet-dashboard'],
      Service['puppet-dashboard-workers'],
    ],
  }

  cron { 'dashboard-purge':
    command => "cd /usr/share/puppet-dashboard; rm -f /usr/share/puppet-dashboard/log/*.log.*; rake RAILS_ENV=production reports:prune upto=${reports_prune_upto_days} unit=day >/dev/null",
    user    => 'root',
    hour    => 3,
    minute  => 10,
  }

}

