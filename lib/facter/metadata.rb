
require 'json'
require 'open-uri'

def grab_variables(object, mata_path=[])
  object.keys.each { |key|
    if object[key].class == Hash
      _meta_path = mata_path.dup
      grab_variables(object[key], _meta_path << key)
    else
      path = ["openstack"]
      if mata_path.length > 0
        path << mata_path.join("-")
      end
      path << key
      Facter.add(path.join("-")) do
        setcode do
          object[key]
        end
      end
    end

  }
end

begin
  Timeout::timeout(20) {
    if  Facter::Util::EC2.has_openstack_mac
      openstack_metadata =  JSON.parse(open("http://169.254.169.254/openstack/2012-08-10/meta_data.json").read)
      grab_variables(openstack_metadata)
    end
  }
rescue Timeout::Error
  puts "openstack-metadata not loaded"
end
