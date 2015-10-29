# Create custom "puppetmaster" boolean fact

if ["/etc/puppet/puppetmaster.conf", "/etc/puppetlabs/puppet/puppetmaster.conf"].map { |x| File.exist? x }.any?
    Facter.add("puppet_puppetmaster") do
        setcode do
            "true"
        end
    end
end

