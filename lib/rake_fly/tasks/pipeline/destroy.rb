# frozen_string_literal: true

require 'ruby_fly'
require 'rake_factory'

module RakeFly
  module Tasks
    module Pipeline
      class Destroy < RakeFactory::Task
        default_name :destroy
        default_prerequisites(RakeFactory::DynamicValue.new do |t|
          [t.fly_ensure_task_name, t.authentication_ensure_task_name]
        end)
        default_description(RakeFactory::DynamicValue.new do |t|
          pipeline = t.pipeline || '<derived>'
          target = t.target || '<derived>'

          "Destroy pipeline #{pipeline} for target #{target}"
        end)

        parameter :target, required: true
        parameter :team
        parameter :pipeline, required: true

        parameter :non_interactive

        parameter :home_directory,
                  default: RakeFactory::DynamicValue.new { |_|
                             Dir.home
                           }

        parameter :fly_ensure_task_name, default: :'fly:ensure'
        parameter :authentication_ensure_task_name,
                  default: :'authentication:ensure'

        action do |t|
          $stdout.puts(
            "Destroying pipeline #{t.pipeline} for target #{t.target}..."
          )
          RubyFly.destroy_pipeline(
            target: t.target,
            team: t.team,
            pipeline: t.pipeline,
            non_interactive: t.non_interactive,
            environment: {
              'HOME' => t.home_directory
            }
          )
        end
      end
    end
  end
end
