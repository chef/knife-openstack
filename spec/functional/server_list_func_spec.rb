require 'spec_helper'
require 'chef/knife/openstack_server_list'
require 'chef/knife/cloud/openstack_service'

describe Chef::Knife::Cloud::OpenstackServerList do
  let (:instance) {Chef::Knife::Cloud::OpenstackServerList.new}

  context "functionality" do
    before do
      resources = [ TestResource.new({:id => "resource-1", :name => "ubuntu01", :addresses => {"public"=>[{"version"=>4, "addr"=>"172.31.6.132"}], "private"=>[{"version"=>4, "addr"=>"172.31.6.133"}]}, :flavor => {"id" => "1"}, :image => {"id" => "image1"}, :key_name => "keypair", :state => "ACTIVE"}),
                     TestResource.new({:id => "resource-2", :name => "windows2008", :addresses => {"public"=>[{"version"=>4, "addr"=>"172.31.6.132"}]}, :flavor => {"id" => "id2"}, :image => {"id" => "image2"}, :key_name => "keypair", :state => "ACTIVE"}),
                     TestResource.new({:id => "resource-3-err", :name => "windows2008", :addresses => {"public"=>[], "private"=>[]}, :flavor => {"id" => "id2"}, :image => {"id" => "image2"}, :key_name => "keypair", :state => "ERROR"})
                   ]
      instance.stub(:query_resource).and_return(resources)
      instance.stub(:puts)
      instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      instance.stub(:validate!)
    end

    it "lists formatted list of resources" do
      instance.ui.should_receive(:list).with(["Instance ID", "Name", "Public IP", "Private IP", "Flavor", "Image", "Keypair", "State",
                                              "resource-1", "ubuntu01", "172.31.6.132", "172.31.6.133", "1", "image1","keypair", "ACTIVE",
                                              "resource-2", "windows2008", "172.31.6.132", nil, "id2", "image2", "keypair", "ACTIVE",
                                              "resource-3-err", "windows2008", nil, nil, "id2", "image2", "keypair", "ERROR"], :uneven_columns_across, 8)
      instance.run
    end
  end
end