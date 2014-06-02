require 'spec_helper'
require 'chef/knife/openstack_network_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackNetworkList do
  let (:instance) {Chef::Knife::Cloud::OpenstackNetworkList.new}

  context "functionality" do
    before do
      resources = [ TestResource.new({:id => "resource-1", :name => "external", :tenant_id => "1", :shared => true}),
                    TestResource.new({:id => "resource-2", :name => "internal", :tenant_id => "2", :shared => false})
                  ]
      instance.stub(:query_resource).and_return(resources)
      instance.stub(:puts)
      instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      instance.stub(:validate!)
    end

    it "lists formatted list of network resources" do
      instance.ui.should_receive(:list).with(["Name", "ID", "Tenant", "Shared",
                                              "external", "resource-1", "1", "true",
                                              "internal", "resource-2", "2", "false"], :uneven_columns_across, 4)
      instance.run
    end
  end
end