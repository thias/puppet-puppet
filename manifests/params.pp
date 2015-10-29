class puppet::params {

  if versioncmp($::puppetversion, '4') > 0 {
    $suffix = 'puppetlabs'
    $confdir = '/etc/puppetlabs/puppet'
    $logdir = '/var/log/puppetlabs/puppet'
    $ssldir = '/etc/puppetlabs/puppet/ssl'
  } else {
    $suffix = 'puppet'
    $confdir = '/etc/puppet'
    $logdir = '/var/log/puppet'
    $ssldir = '/var/lib/puppet/ssl'
  }

  case $::operatingsystem {
    'Fedora', 'RedHat', 'CentOS': {
      $sysconfig = true
      $rundirpre = '/var/run'

    }
    'Gentoo', 'Archlinux': {
      $sysconfig = false
      $rundirpre = '/run'
    }
    default: {
      $sysconfig = false
      $rundirpre = '/var/run'
    }
  }

  $rundir = "${rundirpre}/${suffix}"

}
