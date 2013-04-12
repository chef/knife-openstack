$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef/knife/bootstrap'
require 'chef/knife/winrm_base'
require 'chef/knife/openstack_server_create'
