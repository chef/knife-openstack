require 'spec_helper'
require 'chef/knife/openstack_server_list'
require 'chef/knife/cloud/openstack_service'

describe Chef::Knife::Cloud::OpenstackServerList do
  let (:instance) {Chef::Knife::Cloud::OpenstackServerList.new}

  context "functionality" do
    before do
      @resources = [ TestResource.new({:id => "resource-1", :name => "ubuntu01", :availability_zone => "test zone", :addresses => {"public"=>[{"version"=>4, "addr"=>"172.31.6.132"}], "private"=>[{"version"=>4, "addr"=>"172.31.6.133"}]}, :flavor => {"id" => "1"}, :image => {"id" => "image1"}, :key_name => "keypair", :state => "ACTIVE"}),
                     TestResource.new({:id => "resource-2", :name => "windows2008",:availability_zone => "test zone", :addresses => {"public"=>[{"version"=>4, "addr"=>"172.31.6.132"}]}, :flavor => {"id" => "id2"}, :image => {"id" => "image2"}, :key_name => "keypair", :state => "ACTIVE"}),
                     TestResource.new({:id => "resource-3-err", :name => "windows2008", :availability_zone => "test zone", :addresses => {"public"=>[], "private"=>[]}, :flavor => {"id" => "id2"}, :image => {"id" => "image2"}, :key_name => "keypair", :state => "ERROR"})
                   ]
      instance.stub(:query_resource).and_return(@resources)
      instance.stub(:puts)
      instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::FogService.new)
      instance.stub(:validate!)
    end

    it "lists formatted list of resources" do
      instance.ui.should_receive(:list).with(["Name", "Instance ID", "Public IP", "Private IP", "Flavor", "Image", "Keypair", "State", "Availability Zone",
                                              "ubuntu01", "resource-1", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "test zone",
                                              "windows2008", "resource-2", "172.31.6.132", nil, "id2", "image2", "keypair", "ACTIVE", "test zone", "windows2008", "resource-3-err", nil, nil, "id2", "image2", "keypair", "ERROR", "test zone"], :uneven_columns_across, 9)
      instance.run
    end

    context "when chef-data and chef-node-attribute set" do
      before(:each) do
        @resources.push(TestResource.new({:id => "server-4", :name => "server-4", :availability_zone => "test zone", :addresses => {"public"=>[{"version"=>4, "addr"=>"172.31.6.132"}], "private"=>[{"version"=>4, "addr"=>"172.31.6.133"}]}, :flavor => {"id" => "1"}, :image => {"id" => "image1"}, :key_name => "keypair", :state => "ACTIVE"}))
        @node = TestResource.new({:id => "server-4", :name => "server-4", :chef_environment => "_default", :fqdn => "testfqdnnode.us", :run_list => [], :tags => [], :platform => "ubuntu", :platform_family => "debian"})
        Chef::Node.stub(:list).and_return({"server-4" => @node})
        instance.config[:chef_data] = true
      end

      it "lists formatted list of resources on chef data option set" do
        instance.ui.should_receive(:list).with(["Name", "Instance ID", "Public IP", "Private IP", "Flavor", "Image", "Keypair", "State", "Availability Zone", "Chef Node Name", "Environment", "FQDN", "Runlist", "Tags", "Platform",
                                                "server-4", "server-4", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "test zone", "server-4", "_default", "testfqdnnode.us", "[]", "[]", "ubuntu",
                                                "ubuntu01", "resource-1", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "test zone", "", "", "", "", "", "",
                                                "windows2008", "resource-2", "172.31.6.132", nil, "id2", "image2", "keypair", "ACTIVE", "test zone", "", "", "", "", "", "",
                                                "windows2008", "resource-3-err", nil, nil, "id2", "image2", "keypair", "ERROR", "test zone", "", "", "", "", "", ""], :uneven_columns_across, 15)
        instance.run
      end

      it "lists formatted list of resources on chef-data and chef-node-attribute option set" do
        instance.config[:chef_node_attribute] = "platform_family"
        @node.should_receive(:attribute?).with("platform_family").and_return(true)
        instance.ui.should_receive(:list).with(["Name", "Instance ID", "Public IP", "Private IP", "Flavor", "Image", "Keypair", "State", "Availability Zone", "Chef Node Name", "Environment", "FQDN", "Runlist", "Tags", "Platform", "platform_family",
                                                "server-4", "server-4", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "test zone", "server-4", "_default", "testfqdnnode.us", "[]", "[]", "ubuntu", "debian",
                                                "ubuntu01", "resource-1", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "test zone", "", "", "", "", "", "", "",
                                                "windows2008", "resource-2", "172.31.6.132", nil, "id2", "image2", "keypair", "ACTIVE", "test zone", "", "", "", "", "", "", "",
                                                "windows2008", "resource-3-err", nil, nil, "id2", "image2", "keypair", "ERROR", "test zone", "", "", "", "", "", "", ""], :uneven_columns_across, 16)
        instance.run
      end

      it "raise error on invalid chef-node-attribute set" do
        instance.config[:chef_node_attribute] = "invalid_attribute"
        instance.ui.should_receive(:fatal)
        @node.should_receive(:attribute?).with("invalid_attribute").and_return(false)
        instance.ui.should_receive(:error).with("The Node does not have a invalid_attribute attribute.")
        expect { instance.run }.to raise_error
      end

      it "not display chef-data on chef-node-attribute set but chef-data option missing" do
        instance.config[:chef_data] = false
        instance.config[:chef_node_attribute] = "platform_family"
        instance.ui.should_receive(:list).with(["Name", "Instance ID", "Public IP", "Private IP", "Flavor", "Image", "Keypair", "State", "Availability Zone",
                                                "server-4", "server-4", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "test zone",
                                                "ubuntu01", "resource-1", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "test zone",
                                                "windows2008", "resource-2", "172.31.6.132", nil, "id2", "image2", "keypair", "ACTIVE", "test zone",
                                                "windows2008", "resource-3-err", nil, nil, "id2", "image2", "keypair", "ERROR", "test zone"], :uneven_columns_across, 9)
        instance.run
      end
    end
  end
end
