* Fix repuppet PATH with Puppet Collections agent.
* Improvements with Puppet 4.

#### 2016-09-06 - 1.0.0
* Fix puppetagent.conf.erb with puppet 2.7.
* Add Puppet 4 support (@jesusrodrigo, #10).
* Add support disabling CA for masters (@kostyrevaa, #8).
* Add support for not setting agent environment explicitly (@trosine, #9).

#### 2014-12-16 - 0.6.3
* Fix apache_httpd port with puppet 3.7+.
* Add support for puppetserver runtype.
* Remove autonoop parameter, easy to do the same (and more) with hiera.
* Add support for clojure puppetserver master.

#### 2014-11-26 - 0.6.2
* Add ArchLinux agent support (@edvinasme, #5).
* Fix for updates apache_httpd module.

#### 2014-03-28 - 0.6.1
* Fix silent cron-repuppet since Notice now has uppercase first letter.
* Put the server in the agent puppet.conf section (@CtrlC-Root, #4).
* Remove the server from the repuppet script.
* Sort hashes used in the puppetagent.conf template.

#### 2013-11-21 - 0.6.0
* Update README, including adding an SELinux note (#3).
* Remove httpd directives for passenger 4.0.x compatibility.
* Add scontext master parameter in case it needs to be httpd_t.
* Allow group read on private SSL files, allows to integrate with The Foreman.
* Prefix local fact with puppet_ to avoid conflict with The Foreman.
* Make environment sticky for the agent, now easy to switch nodes.

#### 2013-10-01 - 0.5.5
* Force servername when using apache_httpd for the master.
* Add support for choosing an rsyslog file for puppet-master messages.
* Add new puppet::dashboard class, which still needs some more work.

#### 2013-09-19 - 0.5.4
* Make rundir configurable, changing the default on Gentoo.
* Fix repuppet with puppet agent 3.3.0.
* Remove waitforcert from the default options, as it does not make much sense.

#### 2013-07-18 - 0.5.3
* Fix waitforcert issue with repuppet.

#### 2013-04-19 - 0.5.2
* Work around broken hiera booleans for the agent class.
* Use @variable syntax in templates to remove puppet 3.2 warnings.

#### 2013-04-16 - 0.5.1
* Update examples in the README to have more variety.

#### 2013-04-15 - 0.5.0
* Split out the catpuppetconf into a common class, to fix logic.
* Clean up the master parameters by defaulting most to undef.
* Add missing /etc/puppet/rack content when enabling passenger.
* Silence stderr too from cron, to avoid puppet 3.x error emails.
* Disable waitforcert in repuppet since it must be off for cron runs.
* Configure sysconfig automatically in a new params class.

#### 2012-09-19 - 0.4.1
* Add some more AVC lines to be allowed for passenger puppetmaster.
* Remove legacy cron job removal.
* Disable color for the cron output, makes emails more readable.
* Create a trivial script as verbose cron command, to shorten email subject.

#### 2012-04-24 - 0.4.0
* Clean up the module to match current puppetlabs guidelines.

