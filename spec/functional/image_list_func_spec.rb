require 'spec_helper'
require 'chef/knife/openstack_image_list'
require 'chef/knife/cloud/openstack_service'

describe Chef::Knife::Cloud::OpenstackImageList do
  let (:instance) {Chef::Knife::Cloud::OpenstackImageList.new}

  context "functionality" do
    before do
      resources = [ TestResource.new({:id => "resource-1", :name => "image01", :metadata => {} }),
                     TestResource.new({:id => "resource-2", :name => "initrd", :metadata => {} })
                   ]
      instance.stub(:query_resource).and_return(resources)
      instance.stub(:puts)
      instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      instance.stub(:validate!)
    end

    it "displays formatted list of images, filtered by default" do
      instance.ui.should_receive(:list).with(["Name", "ID", "Snapshot",
                                              "image01", "resource-1", "no"], :uneven_columns_across, 3)
      instance.run
    end

    it "lists all images when disable_filter = true" do
      instance.config[:disable_filter] = true
      instance.ui.should_receive(:list).with(["Name", "ID", "Snapshot",
                                              "image01", "resource-1", "no",
                                              "initrd", "resource-2", "no"], :uneven_columns_across, 3)
      instance.run
    end
  end
end