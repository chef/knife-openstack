require 'spec_helper'
require 'chef/knife/openstack_image_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'
require 'unit/validate_spec'

describe Chef::Knife::Cloud::OpenstackImageList do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackImageList.new

  let (:instance) {Chef::Knife::Cloud::OpenstackImageList.new}

  include_context "#validate!", Chef::Knife::Cloud::OpenstackImageList.new
end
