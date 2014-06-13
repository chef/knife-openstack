require 'spec_helper'
require 'chef/knife/openstack_server_show'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'
require 'unit/validate_spec'

describe Chef::Knife::Cloud::OpenstackServerShow do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackServerShow.new

  include_context "#validate!", Chef::Knife::Cloud::OpenstackServerShow.new
  
  let (:instance) {Chef::Knife::Cloud::OpenstackServerShow.new}

  context "#validate_params!" do
    before(:each) do
      Chef::Config[:knife][:instance_id] = "instance_id"
    end

    it "raise error on instance_id missing" do
      Chef::Config[:knife].delete(:instance_id)
      instance.ui.should_receive(:error).with("You must provide a valid Instance Id")
      expect { instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
    end
  end
end
