require 'ruby_fly'
require_relative '../tasklib'

module RakeFly
  module Tasks
    class GetPipeline < TaskLib
      parameter :name, :default => :get_pipeline

      parameter :target, :required => true
      parameter :pipeline, :required => true

      parameter :ensure_task, :default => :'fly:ensure'

      def process_arguments(args)
        self.name = args[0] if args[0]
      end

      def define
        desc "Get pipeline #{pipeline} for target #{target}"
        task name => [ensure_task] do
          RubyFly.get_pipeline(
              target: target,
              pipeline: pipeline)
        end
      end
    end
  end
end