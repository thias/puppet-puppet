class puppet::params {

  if versioncmp($::puppetversion, '4') >= 0 {
    $puppet4 = true
  } else {
    $puppet4 = false
  }

  if getvar('::puppet_puppetmaster') {
    $master = true
  } else {
    $master = false
  }

  if $puppet4 {
    $suffix = 'puppetlabs'
    $confdir = '/etc/puppetlabs/puppet'
    $logdir = '/var/log/puppetlabs/puppet'
    $ssldir = '/etc/puppetlabs/puppet/ssl'
    $puppet_log = '/var/log/puppetlabs/puppet/puppet.log'
  } else {
    $suffix = 'puppet'
    $confdir = '/etc/puppet'
    $logdir = '/var/log/puppet'
    $ssldir = '$vardir/ssl'
    $puppet_log = '/var/log/puppet/puppet.log'
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
