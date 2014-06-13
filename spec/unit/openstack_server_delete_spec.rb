require 'spec_helper'
require 'chef/knife/openstack_server_delete'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_serverdeletecommand'
require 'unit/validate_spec'

describe Chef::Knife::Cloud::OpenstackServerDelete do
  it_behaves_like Chef::Knife::Cloud::ServerDeleteCommand, Chef::Knife::Cloud::OpenstackServerDelete.new

  include_context "#validate!", Chef::Knife::Cloud::OpenstackServerDelete.new

  let (:instance) {Chef::Knife::Cloud::OpenstackServerDelete.new}

  before(:each) do
    instance.stub(:exit)
  end

  describe "#create_service_instance" do
    it "return OpenstackService instance" do
      expect(instance.create_service_instance).to be_an_instance_of(Chef::Knife::Cloud::OpenstackService)
    end
  end
end
