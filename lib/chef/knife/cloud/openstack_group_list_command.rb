
require 'chef/knife/cloud/list_resource_command'

class Chef
  class Knife
    class Cloud
      class OpenstackGroupListCommand < ResourceListCommand

        # For helper methods
        include OpenstackHelpers

        def query_resource
          @service.connection.security_groups
        end

        def list(security_groups, columns_with_info = [])
          group_list = [
            ui.color('Name', :bold),
            ui.color('Protocol', :bold),
            ui.color('From', :bold),
            ui.color('To', :bold),
            ui.color('CIDR', :bold),
            ui.color('Description', :bold),
          ]
          @service.connection.security_groups.sort_by(&:name).each do |group|
            group.rules.each do |rule|
              unless rule['ip_protocol'].nil?
                group_list << group.name
                group_list << rule['ip_protocol']
                group_list << rule['from_port'].to_s
                group_list << rule['to_port'].to_s
                group_list << rule['ip_range']['cidr']
                group_list << group.description
              end
            end
          end
          puts ui.list(group_list, :uneven_columns_across, 6)
        end

      end # class OpenstackGroupListCommand
    end
  end
end