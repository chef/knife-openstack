require 'spec_helper'
require 'chef/knife/openstack_network_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'
require 'unit/validate_spec'

describe Chef::Knife::Cloud::OpenstackNetworkList do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackNetworkList.new

  let (:instance) {Chef::Knife::Cloud::OpenstackNetworkList.new}

  include_context "#validate!", Chef::Knife::Cloud::OpenstackNetworkList.new
  
  context "query_resource" do
    it "returns the networks using the fog service." do
      instance.service = double
      instance.service.should_receive(:list_networks)
      instance.query_resource
    end
  end
end
