#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
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

shared_context "#validate!" do |instance|
  before(:each) do
    instance.config[:openstack_username] = "testuser"
    instance.config[:openstack_password] = "testpassword"
    instance.config[:openstack_auth_url] = "tsturl"
    instance.config[:openstack_region] = "test-region"
    allow(instance).to receive(:exit)
  end

  it "validate openstack mandatory options" do
    expect { instance.validate! }.to_not raise_error
  end

  it "raise error on openstack_username missing" do
    instance.config.delete(:openstack_username)
    expect(instance.ui).to receive(:error).with("You did not provide a valid 'Openstack Username' value.")
    expect { instance.validate! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
  end

  it "raise error on openstack_password missing" do
    instance.config.delete(:openstack_password)
    expect(instance.ui).to receive(:error).with("You did not provide a valid 'Openstack Password' value.")
    expect { instance.validate! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
  end

  it "raise error on openstack_auth_url missing" do
    instance.config.delete(:openstack_auth_url)
    expect(instance.ui).to receive(:error).with("You did not provide a valid 'Openstack Auth Url' value.")
    expect { instance.validate! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
  end
end
