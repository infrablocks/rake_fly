require 'ruby_fly'
require_relative '../tasklib'

module RakeFly
  module Tasks
    class UnpausePipeline < TaskLib
      parameter :name, :default => :unpause_pipeline

      parameter :target, :required => true
      parameter :pipeline, :required => true

      parameter :ensure_task, :default => :'fly:ensure'

      def process_arguments(args)
        self.name = args[0] if args[0]
      end

      def define
        desc "Unpause pipeline #{pipeline} for target #{target}"
        task name => [ensure_task] do
          RubyFly.unpause_pipeline(
              target: target,
              pipeline: pipeline)
        end
      end
    end
  end
end