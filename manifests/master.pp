class puppet::master (
  $ensure         = 'present',
  $runtype        = 'service',
  $selinux        = $::selinux,
  $scontext       = 'httpd_passenger_helper_t',
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
) {

  include '::puppet::common'

  # Package + partial configuration file + concatenation exec
  if $ensure != 'absent' {

    package { 'puppet-server': ensure => installed }
    if $storeconfigs {
      package { 'rubygem-activerecord': ensure => installed }
    }

    file { '/etc/puppet/puppetmaster.conf':
      owner   => 'root',
      group   => 'puppet',
      mode    => '0640',
      content => template('puppet/puppetmaster.conf.erb'),
    }

    # This will only work once the puppetmaster fact is installed, it's
    # a chicken and egg problem, which we solve here
    if $::puppet_puppetmaster == 'true' {
      # Merge agent+master configs for the master
      File['/etc/puppet/puppetmaster.conf'] ~> Exec['catpuppetconf']
    }

    if $rsyslog_file != false {
      file { '/etc/rsyslog.d/puppet-master.conf':
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('puppet/rsyslog-puppet-master.conf.erb'),
      }
    } else {
      file { '/etc/rsyslog.d/puppet-master.conf': ensure => absent }
    }

  } else {

    file { [
      '/etc/puppet/puppetmaster.conf',
      '/etc/puppet/puppetagent.conf',
      '/etc/rsyslog.d/puppet-master.conf',
    ]:
      ensure => absent,
    }

  }

  # Main puppet master process, with multiple ways of running it
  case $runtype {
    'service': {
      if $::puppet_puppetmaster == 'true' {
        service { 'puppetmaster':
          enable    => true,
          ensure    => running,
          hasstatus => true,
          subscribe => Exec['catpuppetconf'],
        }
      }
      if $selinux and $::selinux_enforced {
        selinux::audit2allow { 'puppetservice':
          source => "puppet:///modules/${module_name}/messages.puppetservice",
        }
      }
    }
    'passenger': {
      $https_certname = $certname ? {
        undef   => $::fqdn,
        default => $certname,
      }
      package { 'mod_passenger': ensure => installed }
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
        owner  => 'root',
        group  => 'root',
        ensure => directory,
      }
      file { '/etc/puppet/rack/public':
        owner  => 'puppet',
        group  => 'puppet',
        ensure => directory,
      }
      file { '/etc/puppet/rack/config.ru':
        owner  => 'puppet',
        group  => 'puppet',
        mode   => '0644',
        source => "puppet:///modules/${module_name}/config.ru",
      }
      if $selinux and $::selinux_enforced {
        selinux::audit2allow { 'puppetpassenger':
          content => template("${module_name}/messages.puppetpassenger.erb"),
        }
      }
    }
    'puppetserver': {
      if $::puppet_puppetmaster == 'true' {
        service { 'puppetserver':
          enable    => true,
          ensure    => running,
          hasstatus => true,
          subscribe => Exec['catpuppetconf'],
        }
      }
      # TODO : SELinux? Still unconfined_java_t as of RHEL 6.6 and 7.0
    }
    'none': {
    }
  }

}

