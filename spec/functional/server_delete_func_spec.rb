require File.expand_path('../../spec_helper', __FILE__)

describe Chef::Knife::OpenstackServerDelete do

  before do
   @openstack_connection = mock(Fog::Compute::OpenStack)

    @knife_openstack_delete = Chef::Knife::OpenstackServerDelete.new
    {
      :image => 'image',
      :openstack_username => 'openstack_username',
      :openstack_password => 'openstack_password',
      :openstack_auth_url => 'openstack_auth_url',
      :server_create_timeout => 1000
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

    @knife_openstack_delete.stub(:msg_pair)
    @knife_openstack_delete.stub(:puts)
    @knife_openstack_delete.stub(:confirm)
    @knife_openstack_delete.ui.stub(:warn)

    @openstack_servers = mock()
    @new_openstack_server = mock()

    @openstack_server_attribs = { :name => 'Mock Server',
                                  :id => 'id-123456',
                                  :key_name => 'key_name',
                                  :flavor => 'flavor_id',
                                  :image => 'image_id',
                                  :addresses => {
                                    'public' => [{'addr' => '75.101.253.10'}],
                                    'private' => [{'addr' => '10.251.75.20'}]
                                    },
                                  :password => 'password'
                                }

    @openstack_server_attribs.each_pair do |attrib, value|
      @new_openstack_server.stub(attrib).and_return(value)
    end
  end

  describe "run" do

    it "should deletes an OpenStack instance." do
      @knife_openstack_delete.name_args = ['test001']
      @openstack_servers.should_receive(:get).and_return(@new_openstack_server)
      @openstack_connection.should_receive(:servers).and_return(@openstack_servers)
      Fog::Compute::OpenStack.should_receive(:new).and_return(@openstack_connection)
      @new_openstack_server.should_receive(:destroy)
      @knife_openstack_delete.run
    end

  end
end
