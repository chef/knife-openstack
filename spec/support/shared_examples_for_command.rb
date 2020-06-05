#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) Chef Software Inc.
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

require "chef/knife/cloud/command"
require "chef/knife/cloud/service"

shared_examples_for Chef::Knife::Cloud::Command do |instance|
  it "runs with correct method calls" do
    allow(instance).to receive(:execute_command)
    allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new(config: instance.config))
    expect(instance).to receive(:set_default_config).ordered
    expect(instance).to receive(:validate!).ordered
    expect(instance).to receive(:validate_params!).ordered
    expect(instance).to receive(:create_service_instance).ordered
    expect(instance).to receive(:before_exec_command).ordered
    expect(instance).to receive(:execute_command).ordered
    expect(instance).to receive(:after_exec_command).ordered
    instance.run
  end
end
