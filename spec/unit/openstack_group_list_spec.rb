require 'spec_helper'
require 'chef/knife/openstack_group_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'
require 'unit/validate_spec'

describe Chef::Knife::Cloud::OpenstackGroupList do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackGroupList.new

  include_context "#validate!", Chef::Knife::Cloud::OpenstackGroupList.new

  let (:instance) {Chef::Knife::Cloud::OpenstackGroupList.new}

  context "#list" do
    before(:each) do
      @security_groups = [TestResource.new({ "name" => "Unrestricted","description" => "testdescription", "security_group_rules" => [TestResource.new({"from_port"=>636, "group"=>{}, "ip_protocol"=>"tcp", "to_port"=>636, "parent_group_id"=>14, "ip_range"=>{"cidr"=>"0.0.0.0/0"}, "id"=>183})]})]
    end

    it "returns group list" do
      instance.ui.should_receive(:list).with(["Name", "Protocol", "From", "To", "CIDR", "Description", "Unrestricted", "tcp", "636", "636", "0.0.0.0/0", "testdescription"],:uneven_columns_across, 6)
      instance.list(@security_groups)
    end
  end
end
