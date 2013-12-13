require 'chef/knife/openstack_base'

class Chef
  class Knife
    class OpenstackNetworkList < Knife

      include Knife::OpenstackBase

      banner "knife openstack network list (options)"

      def run

        validate!

        net_list = [
          ui.color('Name', :bold),
          ui.color('ID', :bold),
          ui.color('Tenant', :bold),
          ui.color('Shared', :bold),
        ]
       network.networks.all.each do |network|
	    net_list << network.name
	    net_list << network.id
            net_list << network.tenant_id
            net_list << network.shared.to_s
        end
        puts ui.list(net_list, :uneven_columns_across, 4)
      end
    end
  end
end
