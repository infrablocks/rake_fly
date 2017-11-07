require 'ruby_fly'
require_relative '../tasklib'

module RakeFly
  module Tasks
    class GetPipeline < TaskLib
      parameter :name, :default => :get_pipeline
      parameter :argument_names, :default => []

      parameter :target, :required => true
      parameter :pipeline, :required => true

      parameter :ensure_task, :default => :'fly:ensure'

      def process_arguments(args)
        self.name = args[0] if args[0]
      end

      def define
        pipeline_name = pipeline.respond_to?(:call) ? "<derived>" : pipeline
        target_name = target.respond_to?(:call) ? "<derived>" : target

        desc "Get pipeline #{pipeline_name} for target #{target_name}"
        task name, argument_names => [ensure_task] do |_, args|
          derived_target = target.respond_to?(:call) ?
              target.call(*[args].slice(0, target.arity)) :
              target
          derived_pipeline = pipeline.respond_to?(:call) ?
              pipeline.call(*[args].slice(0, pipeline.arity)) :
              pipeline

          puts "Getting pipeline #{derived_pipeline} for target #{derived_target}..."
          RubyFly.get_pipeline(
              target: derived_target,
              pipeline: derived_pipeline)
        end
      end
    end
  end
end