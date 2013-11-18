require 'spec_helper'
require 'chef/knife/openstack_server_show'
require 'chef/knife/cloud/openstack_service'

describe Chef::Knife::Cloud::OpenstackServerShow do

  context "functionality" do
    before do
      @instance = Chef::Knife::Cloud::OpenstackServerShow.new
      Chef::Config[:knife][:instance_id] = "instance_id"
      @openstack_service = Chef::Knife::Cloud::OpenstackService.new
      @openstack_service.stub(:msg_pair)
      @openstack_service.stub(:print)
      allow_message_expectations_on_nil
      server = Object.new
      conn = Object.new
      conn.define_singleton_method(:servers){ }
      @openstack_service.stub(:connection).and_return(conn)
      @openstack_service.connection.servers.should_receive(:get).and_return(server)
      @instance.stub(:create_service_instance).and_return(@openstack_service)
      @instance.stub(:validate!)
      @openstack_service.should_receive(:server_summary)
    end

    it "runs server show successfully" do
      @instance.run
    end
  end
end
