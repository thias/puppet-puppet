class puppet::common (
  $confdir = $::puppet::params::confdir,
  ) inherits ::puppet::params {
  exec { 'catpuppetconf':
    command     => "/bin/cat ${confdir}/puppetagent.conf ${confdir}/puppetmaster.conf > ${confdir}/puppet.conf",
    refreshonly => true,
  }
}
