require 'ruby_fly'
require 'rake_factory'

module RakeFly
  module Tasks
    class UnpausePipeline < RakeFactory::Task
      default_name :unpause_pipeline
      default_prerequisites ->(t) { [t.ensure_task_name] }
      default_description ->(t) do
        pipeline = t.pipeline || '<derived>'
        target = t.target || '<derived>'

        "Unpause pipeline #{pipeline} for target #{target}"
      end

      parameter :target, :required => true
      parameter :pipeline, :required => true

      parameter :ensure_task_name, :default => :'fly:ensure'

      action do |t|
        puts "Unpausing pipeline #{t.pipeline} for target #{t.target}..."
        RubyFly.unpause_pipeline(
            target: t.target,
            pipeline: t.pipeline)
      end
    end
  end
end