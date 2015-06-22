#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
# Copyright:: Copyright (c) 2013-2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require 'chef/knife/openstack_group_list'
require 'chef/knife/cloud/openstack_service'

describe Chef::Knife::Cloud::OpenstackGroupList do
  let (:instance) {Chef::Knife::Cloud::OpenstackGroupList.new}

  context "functionality" do
    before do
      resources = [ TestResource.new({ "name" => "Unrestricted",
                                      "description" => "All ports open",
                                      "security_group_rules" => [TestResource.new({"from_port" => 1,
                                                                                   "group" => {},
                                                                                   "ip_protocol" => "tcp",
                                                                                   "to_port" => 636,
                                                                                   "parent_group_id" => 14,
                                                                                   "ip_range" => {"cidr" => "0.0.0.0/0"},
                                                                                   "id" => 1
                                                                                   })
                                                                ]
                                    }),
                    TestResource.new({ "name" => "WindowsDomain",
                                      "description" => "Allows common protocols useful in a Windows domain",
                                      "security_group_rules" => [TestResource.new({"from_port" => 22,
                                                                                   "group" => {},
                                                                                   "ip_protocol" => "tcp",
                                                                                   "to_port" => 636,
                                                                                   "parent_group_id" => 14,
                                                                                   "ip_range" => {"cidr" => "0.0.0.0/0"},
                                                                                   "id" => 2
                                                                                   })
                                                                ]
                                    })
                  ]
      allow(instance).to receive(:query_resource).and_return(resources)
      allow(instance).to receive(:puts)
      allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      allow(instance).to receive(:validate!)
      instance.config[:format] = "summary"
    end

    it "lists formatted list of resources" do
      expect(instance.ui).to receive(:list).with(["Name", "Protocol", "From", "To", "CIDR", "Description",
                                              "Unrestricted", "tcp", "1", "636", "0.0.0.0/0", "All ports open",
                                              "WindowsDomain", "tcp", "22", "636", "0.0.0.0/0", "Allows common protocols useful in a Windows domain"], :uneven_columns_across, 6)
      instance.run
    end
  end
end
