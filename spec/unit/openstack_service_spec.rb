require 'spec_helper'
require 'chef/knife/cloud/openstack_service'
require 'chef/knife/cloud/fog/service'
require 'support/shared_examples_for_fog_service'

describe Chef::Knife::Cloud::OpenstackService do
  it_behaves_like Chef::Knife::Cloud::FogService, Chef::Knife::Cloud::OpenstackService.new
end