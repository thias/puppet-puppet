class puppet::agent (
  $service               = true,
  $sysconfig             = $::puppet::params::sysconfig,
  $master                = $::puppet::params::master,
  # Simple hourly cron job, only if the service is disabled
  $cron_enable           = false,
  $cron_silent           = false,
  $cron_hour             = '*',
  $cron_minute           = fqdn_rand(60),
  # puppet.conf options
  $rundir                = $::puppet::params::rundir,
  $confdir               = $::puppet::params::confdir,
  $logdir                = $::puppet::params::logdir,
  $ssldir                = $::puppet::params::ssldir,
  $pluginsync            = 'true',
  $report                = false,
  $forcenoop             = false,
  $configure_environment = true,
  $main_extraopts        = {},
  $agent_extraopts       = {},
  # sysconfig / repuppet options
  $puppet_server         = 'puppet',
  $puppet_port           = '8140',
  $puppet_log            = $::puppet::params::puppet_log,
  $puppet_extra_opts     = '',
) inherits ::puppet::params {

  include '::puppet::common'

  $puppet4 = $::puppet::params::puppet4

  if $puppet4 {
    $agent_extraopts_filtered = delete($agent_extraopts, 'stringify_facts')
  } else {
    $agent_extraopts_filtered = $agent_extraopts
  }

  # Configuration changes, make it easy to deploy new options
  # and change to mode 600 so that regular users can't easily find the server
  if $sysconfig {
    file { '/etc/sysconfig/puppet':
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => template('puppet/sysconfig-puppet.erb'),
    }
  }
  # Main configuration for the service. Always install, just in case the
  # service is run when it shouldn't have been (we respect noop here).
  if $master {
    $agentconfname = "${confdir}/puppetagent.conf"
    $agentconfmode = '0644'
    File[$agentconfname] ~> Exec['catpuppetconf']
  } else {
    $agentconfname = "${confdir}/puppet.conf"
    $agentconfmode = '0640'
  }
  file { $agentconfname:
    owner   => 'root',
    group   => 'root',
    mode    => $agentconfmode,
    content => template('puppet/puppetagent.conf.erb'),
  }

  # Lock down puppet logs, to not give everyone read access to them
  # Puppet automatically changes ownership to 'puppet' if user/group exist
  file { $logdir:
    ensure => 'directory',
    owner  => undef,
    group  => undef,
    mode   => '0750',
  }

  if $service == true {
    service { 'puppet':
      ensure    => 'running',
      enable    => true,
      hasstatus => true,
      # Make sure puppet reloads (HUP) after configuration changes...
      # Does not work, see http://projects.puppetlabs.com/issues/1273
      restart   => '/sbin/service puppet reload',
      subscribe => File[$agentconfname],
    }
  } else {
    # Disable running puppet as a service when it takes so much memory
    service { 'puppet':
      ensure    => 'stopped',
      enable    => false,
      hasstatus => true,
    }
    if $cron_enable {
      if $forcenoop { $cmd_noop = ' --noop' } else { $cmd_noop = '' }
      # We might not care about the output when we have a Dashboard
      if $cron_silent {
        $cron_command = "/usr/local/sbin/repuppet${cmd_noop} &>/dev/null"
      } else {
        $cron_command = '/usr/local/sbin/cron-repuppet'
        file { '/usr/local/sbin/cron-repuppet':
          owner   => 'root',
          group   => 'root',
          mode    => '0750',
          content => "#!/bin/bash \n/usr/local/sbin/repuppet${cmd_noop} --show_diff --color=false | egrep -i -v '^Notice: (Applied|Finished) catalog '\n",
        }
      }
      cron { 'puppet-agent':
        command => $cron_command,
        user    => 'root',
        hour    => $cron_hour,
        minute  => $cron_minute,
      }
    } else {
      file { '/usr/local/sbin/cron-repuppet': ensure => absent }
    }
  }

  # Useful script to force a puppet run at any time
  file { '/usr/local/sbin/repuppet':
    mode    => '0750',
    content => template('puppet/repuppet.erb'),
  }

}

