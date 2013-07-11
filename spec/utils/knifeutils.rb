require 'active_support/concern'
require 'mixlib/shellout'
module RSpec
  module KnifeUtils    
    extend ActiveSupport::Concern
    included do
      subject { knife_run }
      let(:knife_run) { run command }
      let(:command)   { fail 'Define let(:command) in the spec' }
      let(:cmd_stdout) { @op }

      # Convenience method for actually running a knife command in our
      # testing repository.  Returns the Mixlib::Shellout object ready for
      # inspection.
      def run(command_line)
        shell_out = Mixlib::ShellOut.new("#{command_line}" + " -V")
        @op = shell_out.tap(&:run_command).stdout        
        return shell_out
      end

      def knife(knife_command)
        run "knife #{knife_command}"
      end
    end
    # Convenience function for grabbing a hash of several important
    # Mixlib::Shellout command configuration parameters.
    def self.command_setting(shellout_command)
      keys = [:cwd, :user, :group, :umask, :timeout, :valid_exit_codes, :environment]
      keys.inject({}) do |hash, attr|
        hash[attr] = shellout_command.send(attr)
        hash
      end
    end
  end
end
