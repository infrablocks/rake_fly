# frozen_string_literal: true

require 'ruby_fly'
require 'rake_factory'
require 'concourse'

module RakeFly
  module Tasks
    module Authentication
      class Ensure < RakeFactory::Task
        default_name :ensure
        default_prerequisites(RakeFactory::DynamicValue.new do |t|
          [t.fly_ensure_task_name]
        end)
        default_description(RakeFactory::DynamicValue.new do |t|
          target = t.target || '<derived>'

          "Ensure logged in for target #{target}"
        end)

        parameter :target, required: true

        parameter :home_directory,
                  default: RakeFactory::DynamicValue.new { |_|
                             Dir.home
                           }

        parameter :login_task_name, default: :login

        parameter :fly_ensure_task_name, default: :'fly:ensure'

        action do |t, args|
          $stdout.puts("Ensuring target #{t.target} is logged in...")

          Dir.mkdir(t.home_directory)

          status = RubyFly.status(
            target: t.target,
            environment: {
              'HOME' => t.home_directory
            }
          )
          if status == :logged_in
            $stdout.puts('Already logged in. Continuing...')
          else
            $stdout.puts('Not logged in. Logging in...')
            t.application[t.login_task_name, t.scope].invoke(*args)
          end
        end
      end
    end
  end
end
