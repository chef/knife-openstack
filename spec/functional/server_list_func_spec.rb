require 'spec_helper'
require 'chef/knife/openstack_server_list'
require 'chef/knife/cloud/openstack_service'

describe Chef::Knife::Cloud::OpenstackServerList do
  let (:instance) {Chef::Knife::Cloud::OpenstackServerList.new}

  context "functionality" do
    before do
      @resources = [ TestResource.new({:id => "resource-1", :name => "ubuntu01", :addresses => {"public"=>[{"version"=>4, "addr"=>"172.31.6.132"}], "private"=>[{"version"=>4, "addr"=>"172.31.6.133"}]}, :flavor => {"id" => "1"}, :image => {"id" => "image1"}, :key_name => "keypair", :state => "ACTIVE"}),
                     TestResource.new({:id => "resource-2", :name => "windows2008", :addresses => {"public"=>[{"version"=>4, "addr"=>"172.31.6.132"}]}, :flavor => {"id" => "id2"}, :image => {"id" => "image2"}, :key_name => "keypair", :state => "ACTIVE"}),
                     TestResource.new({:id => "resource-3-err", :name => "windows2008", :addresses => {"public"=>[], "private"=>[]}, :flavor => {"id" => "id2"}, :image => {"id" => "image2"}, :key_name => "keypair", :state => "ERROR"})
                   ]
      instance.stub(:query_resource).and_return(@resources)
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

    context "when chef-data and chef-node-attribute set" do
      before(:each) do
        @resources.push(TestResource.new({:id => "server-4", :name => "server-4", :addresses => {"public"=>[{"version"=>4, "addr"=>"172.31.6.132"}], "private"=>[{"version"=>4, "addr"=>"172.31.6.133"}]}, :flavor => {"id" => "1"}, :image => {"id" => "image1"}, :key_name => "keypair", :state => "ACTIVE"}))
        @node = TestResource.new({:id => "server-4", :name => "server-4", :chef_environment => "_default", :fqdn => "testfqdnnode.us", :run_list => [], :tags => [], :platform => "ubuntu", :platform_family => "debian"})
        Chef::Node.stub(:list).and_return({"server-4" => @node})
        instance.config[:chef_data] = true
      end

      it "lists formatted list of resources on chef data option set" do
        instance.ui.should_receive(:list).with(["Instance ID", "Name", "Public IP", "Private IP", "Flavor", "Image", "Keypair", "State", "Chef Node Name", "Environment", "FQDN", "Runlist", "Tags", "Platform", "resource-1", "ubuntu01", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "", "", "", "", "", "", "resource-2", "windows2008", "172.31.6.132", nil, "id2", "image2", "keypair", "ACTIVE", "", "", "", "", "", "", "resource-3-err", "windows2008", nil, nil, "id2", "image2", "keypair", "ERROR", "", "", "", "", "", "","server-4", "server-4", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "server-4", "_default", "testfqdnnode.us", "[]", "[]", "ubuntu"], :uneven_columns_across, 14)
        instance.run
      end

      it "lists formatted list of resources on chef-data and chef-node-attribute option set" do
        instance.config[:chef_node_attribute] = "platform_family"
        @node.should_receive(:attribute?).with("platform_family").and_return(true)
        instance.ui.should_receive(:list).with(["Instance ID", "Name", "Public IP", "Private IP", "Flavor", "Image", "Keypair", "State", "Chef Node Name", "Environment", "FQDN", "Runlist", "Tags", "Platform", "platform_family", "resource-1", "ubuntu01", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "", "", "", "", "", "", "", "resource-2", "windows2008", "172.31.6.132", nil, "id2", "image2", "keypair", "ACTIVE", "", "", "", "", "", "", "", "resource-3-err", "windows2008", nil, nil, "id2", "image2", "keypair", "ERROR", "", "", "","","","","","server-4", "server-4", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "server-4", "_default", "testfqdnnode.us", "[]", "[]", "ubuntu", "debian"], :uneven_columns_across, 15)
        instance.run
      end

      it "raise error on invalid chef-node-attribute set" do
        instance.config[:chef_node_attribute] = "invalid_attribute"
        @node.should_receive(:attribute?).with("invalid_attribute").and_return(false)
        instance.ui.should_receive(:error).with("The Node does not have a invalid_attribute attribute.")
        expect { instance.run }.to raise_error
      end

      it "not display chef-data on chef-node-attribute set but chef-data option missing" do
        instance.config[:chef_data] = false
        instance.config[:chef_node_attribute] = "platform_family"
        instance.ui.should_not_receive(:list).with(["Instance ID", "Name", "Public IP", "Private IP", "Flavor", "Image", "Keypair", "State", "Chef Node Name", "Environment", "FQDN", "Runlist", "Tags", "Platform", "resource-1", "ubuntu01", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "", "", "", "", "", "", "resource-2", "windows2008", "172.31.6.132", nil, "id2", "image2", "keypair", "ACTIVE", "", "", "", "", "", "", "server-4", "server-4", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE",  "resource-3-err", "windows2008", nil, nil, "id2", "image2", "keypair", "ERROR", "", "", "", "", "", "","server-4", "_default", "testfqdnnode.us", "[]", "[]", "ubuntu"], :uneven_columns_across, 14)
        instance.ui.should_receive(:list).with(["Instance ID", "Name", "Public IP", "Private IP", "Flavor", "Image", "Keypair", "State", "resource-1", "ubuntu01", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE", "resource-2", "windows2008", "172.31.6.132", nil, "id2", "image2", "keypair", "ACTIVE", "resource-3-err", "windows2008", nil, nil, "id2", "image2", "keypair", "ERROR","server-4", "server-4", "172.31.6.132", "172.31.6.133", "1", "image1", "keypair", "ACTIVE"], :uneven_columns_across, 8)
        instance.run
      end
    end
  end
end
