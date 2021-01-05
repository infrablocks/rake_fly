require 'ruby_fly'
require 'rake_factory'
require 'concourse'

module RakeFly
  module Tasks
    module Authentication
      class Ensure < RakeFactory::Task
        default_name :ensure
        default_prerequisites RakeFactory::DynamicValue.new { |t|
          [t.ensure_task_name]
        }
        default_description RakeFactory::DynamicValue.new { |t|
          target = t.target || '<derived>'

          "Ensure logged in for target #{target}"
        }

        parameter :target, required: true

        parameter :home_directory,
            default: RakeFactory::DynamicValue.new { |_| ENV['HOME'] }

        parameter :ensure_task_name, :default => :'fly:ensure'

        action do |t, args|
          puts "Ensuring target #{t.target} is logged in..."
          status = RubyFly.status(
              target: t.target,
              environment: {
                  "HOME" => t.home_directory
              })
          if status == :logged_in
            puts "Already logged in. Continuing..."
          else
            puts "Not logged in. Logging in..."
            t.application[:login, t.scope].invoke(*args)
          end
        end
      end
    end
  end
end