require 'rspec'
require File.expand_path(File.dirname(__FILE__) +'../../utils/knifeutils')

RSpec::Matchers.define :have_outcome do |outcome_spec|
  match do |executed_shellout_command|
    valid_keys =  [:status, :stdout, :stderr]
    if outcome_spec.keys & valid_keys == []
      throw "You did not specify values for any of #{valid_keys}!"
    end
    print
    @status = outcome_spec[:status] ? (executed_shellout_command.exitstatus == outcome_spec[:status]) : true
    @stdout = outcome_spec[:stdout] ? (executed_shellout_command.stdout =~ outcome_spec[:stdout]) : true
    @stderr = outcome_spec[:stderr] ? (executed_shellout_command.stderr =~ outcome_spec[:stderr]) : true
    @status && @stdout && @stderr
  end
  # Could just spit out `executed_shellout_command.inspect`, but I
  # find the formatting suboptimal for testing error messages.
  failure_message_for_should do |executed_shellout_command|
    "Executed command should have matched the outcome spec #{outcome_spec.inspect}, but it didn't!\n
\tFailed Command: #{executed_shellout_command.command}\n
\tCommand Setting: #{RSpec::KnifeUtils.command_setting(executed_shellout_command).inspect}\n
\tExit Status: #{executed_shellout_command.exitstatus}\n
\tStandard Output:\n
#{executed_shellout_command.stdout}\n
\tStandard Error:\n
#{executed_shellout_command.stderr}"
  end

end
