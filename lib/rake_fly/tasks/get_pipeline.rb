require 'ruby_fly'
require 'rake_factory'

module RakeFly
  module Tasks
    class GetPipeline < RakeFactory::Task
      default_name :get_pipeline
      default_prerequisites RakeFactory::DynamicValue.new { |t|
        [t.ensure_task_name]
      }
      default_description RakeFactory::DynamicValue.new { |t|
        pipeline = t.pipeline || '<derived>'
        target = t.target || '<derived>'

        "Get pipeline #{pipeline} for target #{target}"
      }

      parameter :target, :required => true
      parameter :pipeline, :required => true

      parameter :ensure_task_name, :default => :'fly:ensure'

      action do |t|
        puts "Getting pipeline #{t.pipeline} for target #{t.target}..."
        RubyFly.get_pipeline(
            target: t.target,
            pipeline: t.pipeline)
      end
    end
  end
end