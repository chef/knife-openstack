#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
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

$:.unshift File.expand_path("../lib", __dir__)
require "json"

# Creates a resource class that can dynamically add attributes to
# instances and set the values
module JSONModule
  def to_json
    hash = {}
    instance_variables.each do |var|
      hash[var] = instance_variable_get var
    end
    hash.to_json
  end

  def from_json!(string)
    JSON.load(string).each do |var, val|
      instance_variable_set var, val
    end
  end
end

class TestResource
  include JSONModule
  def initialize(*args)
    args.each do |arg|
      arg.each do |key, value|
        add_attribute = "class << self; attr_accessor :#{key}; end"
        eval(add_attribute) # rubocop:disable Security/Eval
        eval("@#{key} = value") # rubocop:disable Security/Eval
      end
    end
  end
end
