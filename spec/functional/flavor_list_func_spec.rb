require 'spec_helper'
require 'chef/knife/openstack_flavor_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackFlavorList do
  let (:instance) {Chef::Knife::Cloud::OpenstackFlavorList.new}

  context "functionality" do
    before do
      resources = [ TestResource.new({:id => "resource-1", :name => "m1.tiny", :vcpus => "1", :ram => 512, :disk => 0}),
                     TestResource.new({:id => "resource-2", :name => "m1-xlarge-bigdisk", :vcpus => "8", :ram => 16384, :disk => 50})
                   ]
      instance.stub(:query_resource).and_return(resources)
      instance.stub(:puts)
      instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      instance.stub(:validate!)
    end

    it "lists formatted list of resources" do
      instance.ui.should_receive(:list).with(["Name", "ID", "Virtual CPUs", "RAM", "Disk",
                                              "m1-xlarge-bigdisk", "resource-2", "8", "16384 MB", "50 GB",
                                              "m1.tiny", "resource-1", "1", "512 MB", "0 GB"], :uneven_columns_across, 5)
      instance.run
    end
  end
end