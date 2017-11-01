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
        desc "Get pipeline #{pipeline} for target #{target}"
        task name, argument_names => [ensure_task] do |_, args|
          derived_target = target.respond_to?(:call) ?
              target.call(*[args].slice(0, target.arity)) :
              target
          derived_pipeline = pipeline.respond_to?(:call) ?
              pipeline.call(*[args].slice(0, pipeline.arity)) :
              pipeline

          puts "Getting pipeline #{pipeline} for target #{target}..."
          RubyFly.get_pipeline(
              target: derived_target,
              pipeline: derived_pipeline)
        end
      end
    end
  end
end