class puppet::common {
  exec { 'catpuppetconf':
    command     => '/bin/cat /etc/puppet/puppetagent.conf /etc/puppet/puppetmaster.conf > /etc/puppet/puppet.conf',
    refreshonly => true,
  }
}

