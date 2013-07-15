require 'spec_helper'
require 'chef/knife/openstack_group_list'
require 'chef/knife/cloud/openstack_service'

describe Chef::Knife::Cloud::OpenstackGroupList do
  let (:instance) {Chef::Knife::Cloud::OpenstackGroupList.new}

  context "functionality" do
    before do
      resources = [ TestResource.new({:name => "Unrestricted", :rules => ["from_port"=>1, "group"=>{}, "ip_protocol"=>"tcp", "to_port"=>65535, "parent_group_id"=>14, "ip_range"=>{"cidr"=>"0.0.0.0/0"}, "id"=>88], :description => "All ports open"}),
                     TestResource.new({:name => "WindowsDomain", :rules => ["from_port"=>22, "group"=>{}, "ip_protocol"=>"tcp", "to_port"=>22, "parent_group_id"=>12, "ip_range"=>{"cidr"=>"0.0.0.0/0"}, "id"=>58], :description => "Allows common protocols useful in a Windows domain"})
                   ]
      instance.stub(:query_resource).and_return(resources)
      instance.stub(:puts)
      instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      instance.stub(:validate!)
    end

    it "lists formatted list of resources" do
      instance.ui.should_receive(:list).with(["Name", "Protocol", "From", "To", "CIDR", "Description",
                                              "Unrestricted", "tcp", "1", "65535", "0.0.0.0/0", "All ports open",
                                              "WindowsDomain", "tcp", "22", "22", "0.0.0.0/0", "Allows common protocols useful in a Windows domain"], :uneven_columns_across, 6)
      instance.run
    end
  end
end