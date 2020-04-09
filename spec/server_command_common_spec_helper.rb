#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
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

$:.unshift File.expand_path("../../lib", __FILE__)

# Common helper methods used accrossed knife plugin during Integration testing.
#
# run_cmd_check_status_and_output: It checks knife plugin command exitstatus(i.e '0' = succeed and '1' = fails)
# and also checks command output(i.e stdout or stderr)
#
# run_cmd_check_stdout: It checks commands stdout.
#
# server_create_common_bfr_aftr: Its contains common before and after blocks used for server create

def run_cmd_check_status_and_output(expected_status = "succeed", expected_result = nil)
  it do
    match_status("should #{expected_status}")
    expect(cmd_output).to include(expected_result) if expected_result
  end
end

def run_cmd_check_stdout(expected_result)
  it { match_stdout(/#{expected_result}/) }
end

def server_create_common_bfr_aftr(platform = "linux")
  before { create_node_name(platform) }
  after { run(delete_instance_cmd("#{cmd_output}")) }
end

def rm_known_host
  known_hosts = File.expand_path("~") + "/.ssh/known_hosts"
  FileUtils.rm_rf(known_hosts)
end
