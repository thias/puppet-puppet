class puppet::params {
  case $::operatingsystem {
    'Fedora', 'RedHat', 'CentOS': {
      $sysconfig = true
      $rundir = '/var/run/puppet'
      $ssldir = '\$vardir/ssl'
    }
    'Gentoo', 'Archlinux': {
      $sysconfig = false
      $rundir = '/run/puppet'
    }
    default: {
      $sysconfig = false
      $rundir = '/var/run/puppet'
    }
  }
}

