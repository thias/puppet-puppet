class puppet::master (
  $ensure         = 'present',
  $runtype        = 'service',
  $selinux        = getvar('os.selinux'),
  $scontext       = 'httpd_passenger_helper_t',
  $ca_server      = true,
  $confdir        = $::puppet::params::confdir,
  # puppet.conf options
  $certname       = undef,
  $dns_alt_names  = undef,
  $reports        = undef,
  $reporturl      = undef,
  $storeconfigs   = undef,
  $storeconfigs_backend = undef,
  $dbadapter      = undef,
  $dbserver       = undef,
  $dbname         = undef,
  $dbuser         = undef,
  $dbpassword     = undef,
  $dbsocket       = undef,
  $rsyslog_file   = false,
  $extraopts      = {},
) inherits ::puppet::params {

  include '::puppet::common'

  $puppetmaster = $::puppet::params::master

  # Package + partial configuration file + concatenation exec
  if $ensure != 'absent' {

    $puppet4 = $::puppet::params::puppet4

    if ! $puppet4 {
      package { 'puppet-server': ensure => 'installed' }
      if $storeconfigs {
        package { 'rubygem-activerecord': ensure => 'installed' }
      }
    }

    file { "${confdir}/puppetmaster.conf":
      owner   => 'root',
      group   => 'puppet',
      mode    => '0640',
      content => template('puppet/puppetmaster.conf.erb'),
    }

    # This will only work once the puppetmaster fact is installed, it's
    # a chicken and egg problem, which we solve here
    if $puppetmaster == 'true' {
      # Merge agent+master configs for the master
      File["${confdir}/puppetmaster.conf"] ~> Exec['catpuppetconf']
    }

    if $rsyslog_file != false {
      file { '/etc/rsyslog.d/puppet-master.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('puppet/rsyslog-puppet-master.conf.erb'),
      }
    } else {
      file { '/etc/rsyslog.d/puppet-master.conf': ensure => 'absent' }
    }

  } else {

    file { [
      "${confdir}/puppetmaster.conf",
      "${confdir}/puppetagent.conf",
      "/etc/rsyslog.d/puppet-master.conf",
    ]:
      ensure => 'absent',
    }

  }

  # Main puppet master process, with multiple ways of running it
  case $runtype {
    'service': {
      if $puppetmaster == 'true' {
        service { 'puppetmaster':
          ensure    => 'running',
          enable    => true,
          hasstatus => true,
          subscribe => Exec['catpuppetconf'],
        }
      }
      if $selinux and $facts.get('os.selinux.enabled') {
        selinux::audit2allow { 'puppetservice':
          source => "puppet:///modules/${module_name}/messages.puppetservice",
        }
      }
    }
    'passenger': {
      $https_certname = $certname ? {
        undef   => $facts['networking']['fqdn'],
        default => $certname,
      }
      package { 'mod_passenger': ensure => 'installed' }
      file { '/etc/httpd/conf.d/puppet.conf':
        owner   => 'root',
        group   => 'root',
        content => template('puppet/httpd-puppet.conf.erb'),
        notify  => Service['httpd'],
      }
      class { '::apache_httpd':
        mpm        => 'worker',
        listen     => [ '8140' ],
        ssl        => true,
        modules    => [
          'auth_basic',
          'authz_host',
          'headers',
          'mime',
          'negotiation',
          'dir',
          'alias',
          'rewrite',
        ],
        user       => 'puppet',
        group      => 'puppet',
        servername => "${https_certname}:8140",
        welcome    => false,
      }
      file { '/etc/puppet/rack':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
      }
      file { '/etc/puppet/rack/public':
        ensure => 'directory',
        owner  => 'puppet',
        group  => 'puppet',
      }
      file { '/etc/puppet/rack/config.ru':
        owner  => 'puppet',
        group  => 'puppet',
        mode   => '0644',
        source => "puppet:///modules/${module_name}/config.ru",
      }
      if $selinux and $facts.get('os.selinux.enabled') {
        selinux::audit2allow { 'puppetpassenger':
          content => template("${module_name}/messages.puppetpassenger.erb"),
        }
      }
    }
    'puppetserver': {
      if $puppetmaster == 'true' {
        package { 'puppetserver': ensure => 'installed' }
        service { 'puppetserver':
          ensure    => 'running',
          enable    => true,
          subscribe => Exec['catpuppetconf'],
        }
      }
      # TODO : SELinux? Still unconfined_java_t as of RHEL 6.6 and 7.0
    }
    'none': {
    }
  }

}

