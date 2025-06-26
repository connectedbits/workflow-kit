require "bundler/setup"

GEMS = %w(feel dmn bpmn)

task default: :test

%w(test).each do |task_name|
  desc "Run #{task_name} task for all projects"
  task task_name do
    errors = []
    GEMS.each do |project|
      system(%(cd #{project} && bin/rake #{task_name} --trace)) || errors << project
    end
    fail("Errors in #{errors.join(', ')}") unless errors.empty?
  end
end
