require File.expand_path('../../spec_helper', __FILE__)

describe Chef::Knife::OpenstackServerDelete do

  before do
    @openstack_connection = mock(Fog::Compute::OpenStack)
    @chef_node = mock(Chef::Node)
    @chef_client = mock(Chef::ApiClient)
    @knife_openstack_delete = Chef::Knife::OpenstackServerDelete.new
    {
      :openstack_username => 'openstack_username',
      :openstack_password => 'openstack_password',
      :openstack_auth_url => 'openstack_auth_url'
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

    @knife_openstack_delete.stub(:msg_pair)
    @knife_openstack_delete.stub(:puts)
    @knife_openstack_delete.stub(:confirm)
    @knife_openstack_delete.ui.stub(:warn)
    @openstack_servers = mock()
    @running_openstack_server = mock()
    @openstack_server_attribs = { :name => 'Mock Server',
                                  :id => 'id-123456',
                                  :flavor => 'flavor_id',
                                  :image => 'image_id',
                                  :addresses => {
                                    'public' => [{'addr' => '75.101.253.10'}],
                                    'private' => [{'addr' => '10.251.75.20'}]
                                    }
                                }

    @openstack_server_attribs.each_pair do |attrib, value|
      @running_openstack_server.stub(attrib).and_return(value)
    end
    @knife_openstack_delete.name_args = ['test001']
  end

  describe "run" do
    it "deletes an OpenStack instance." do
      @openstack_servers.should_receive(:get).and_return(@running_openstack_server)
      @openstack_connection.should_receive(:servers).and_return(@openstack_servers)
      Fog::Compute::OpenStack.should_receive(:new).and_return(@openstack_connection)
      @running_openstack_server.should_receive(:destroy)
      @knife_openstack_delete.run
    end

    it "deletes the instance along with the node and client on the chef-server when --purge is given as an option." do
      @knife_openstack_delete.config[:purge] = true
      Chef::Node.should_receive(:load).and_return(@chef_node)
      @chef_node.should_receive(:destroy)
      Chef::ApiClient.should_receive(:load).and_return(@chef_client)
      @chef_client.should_receive(:destroy)
      @openstack_servers.should_receive(:get).and_return(@running_openstack_server)
      @openstack_connection.should_receive(:servers).and_return(@openstack_servers)
      Fog::Compute::OpenStack.should_receive(:new).and_return(@openstack_connection)
      @running_openstack_server.should_receive(:destroy)
      @knife_openstack_delete.run
    end
  end
end
