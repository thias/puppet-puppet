# Create custom "puppetmaster" boolean fact

binaries = [
  '/opt/puppetlabs/bin/puppetserver',
  '/bin/puppetserver',
  '/usr/bin/puppetserver',
  '/usr/sbin/puppetserver',
  '/usr/local/bin/puppetserver',
  '/usr/local/sbin/puppetserver',
]

binaries.each do |filename|
  if File.exists?(filename)
    Facter.add('puppet_puppetmaster') { setcode { true } }
    Facter.add('puppet_puppetmaster_version') do
      setcode do
        version = Facter::Util::Resolution.exec("#{filename} --version 2>/dev/null")
        version.match(%r{\d+\.\d+\.\d+})[0] if version
      end
    end
  end
end
