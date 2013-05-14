#  A Puppet Facter plugin to create facts from the openstack metadata service
#  Copyright (C) 2012 NigelB
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
        path << mata_path.join("_")
      end
      path << key
      Facter.add(path.join("_")) do
        setcode do
          if object[key].class == Array
            object[key].join(",")
          else
            object[key]
          end
        end
      end
    end

  }
end

begin
#	if  Facter::Util::EC2.has_openstack_mac

		begin
			openstack_metadata = JSON.parse(open("/etc/openstack/meta_data.json").read)
			grab_variables(openstack_metadata)
			rescue  Errno::ENOENT
				puts "No Local OpenStack meta data available."
		end
		begin
			openstack_metadata = JSON.parse(open("http://169.254.169.254/openstack/2012-08-10/meta_data.json").read)
			grab_variables(openstack_metadata)
			rescue OpenURI::HTTPError
			  puts "openstack-metadata not loaded"
		end
#	end

end
