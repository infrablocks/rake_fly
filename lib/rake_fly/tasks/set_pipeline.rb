require 'ruby_fly'
require_relative '../tasklib'

module RakeFly
  module Tasks
    class SetPipeline < TaskLib
      parameter :name, :default => :set_pipeline

      parameter :target, :required => true
      parameter :pipeline, :required => true
      parameter :config, :required => true

      parameter :vars
      parameter :var_files
      parameter :non_interactive

      parameter :ensure_task, :default => :'fly:ensure'

      def process_arguments(args)
        self.name = args[0] if args[0]
      end

      def define
        desc "Set pipeline #{pipeline} for target #{target}"
        task name => [ensure_task] do
          puts "Setting pipeline #{pipeline} for target #{target}..."
          RubyFly.set_pipeline(
              target: target,
              pipeline: pipeline,
              config: config,
              vars: vars,
              var_files: var_files,
              non_interactive: non_interactive)
        end
      end
    end
  end
end