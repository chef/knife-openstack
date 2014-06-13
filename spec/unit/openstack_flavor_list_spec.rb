require 'spec_helper'
require 'chef/knife/openstack_flavor_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'
require 'unit/validate_spec'

describe Chef::Knife::Cloud::OpenstackFlavorList do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackFlavorList.new

  include_context "#validate!", Chef::Knife::Cloud::OpenstackFlavorList.new
end
