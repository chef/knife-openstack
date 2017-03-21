# frozen_string_literal: true
require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud
      class OpenstackGroupList < ResourceListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner 'knife openstack group list (options)'

        def query_resource
          @service.connection.security_groups
        rescue Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end

        def list(security_groups)
          if config[:format] == 'summary'
            group_list = [
              ui.color('Name', :bold),
              ui.color('Protocol', :bold),
              ui.color('From', :bold),
              ui.color('To', :bold),
              ui.color('CIDR', :bold),
              ui.color('Description', :bold)
            ]
            security_groups.sort_by(&:name).each do |group|
              group.security_group_rules.each do |rule|
                next if rule.ip_protocol.nil?
                group_list << group.name
                group_list << rule.ip_protocol
                group_list << rule.from_port.to_s
                group_list << rule.to_port.to_s
                group_list << rule.ip_range['cidr']
                group_list << group.description
              end
            end

            puts ui.list(group_list, :uneven_columns_across, 6)
          else
            output(format_for_display(security_groups))
          end
        end
      end
    end
  end
end
