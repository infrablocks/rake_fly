require 'ruby_fly'
require 'rake_factory'

module RakeFly
  module Tasks
    module Pipeline
      class Unpause < RakeFactory::Task
        default_name :unpause
        default_prerequisites RakeFactory::DynamicValue.new { |t|
          [t.ensure_task_name]
        }
        default_description RakeFactory::DynamicValue.new { |t|
          pipeline = t.pipeline || '<derived>'
          target = t.target || '<derived>'

          "Unpause pipeline #{pipeline} for target #{target}"
        }

        parameter :target, :required => true
        parameter :team
        parameter :pipeline, :required => true

        parameter :ensure_task_name, :default => :'fly:ensure'

        action do |t|
          puts "Unpausing pipeline #{t.pipeline} for target #{t.target}..."
          RubyFly.unpause_pipeline(
              target: t.target,
              team: t.team,
              pipeline: t.pipeline)
        end
      end
    end
  end
end
