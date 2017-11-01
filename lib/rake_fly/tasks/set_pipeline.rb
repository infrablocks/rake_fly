require 'ruby_fly'
require_relative '../tasklib'

module RakeFly
  module Tasks
    class SetPipeline < TaskLib
      parameter :name, :default => :set_pipeline
      parameter :argument_names, :default => []

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
        task name, argument_names => [ensure_task] do |_, args|
          derived_target = target.respond_to?(:call) ?
                               target.call(*[args].slice(0, target.arity)) :
                               target
          derived_pipeline = pipeline.respond_to?(:call) ?
                                 pipeline.call(*[args].slice(0, pipeline.arity)) :
                                 pipeline
          derived_config = config.respond_to?(:call) ?
                                 config.call(*[args].slice(0, config.arity)) :
                                 config
          derived_vars = vars.respond_to?(:call) ?
                             vars.call(*[args].slice(0, vars.arity)) :
                             vars
          derived_var_files = var_files.respond_to?(:call) ?
                             var_files.call(*[args].slice(0, var_files.arity)) :
                             var_files

          puts "Setting pipeline #{pipeline} for target #{target}..."
          RubyFly.set_pipeline(
              target: derived_target,
              pipeline: derived_pipeline,
              config: derived_config,
              vars: derived_vars,
              var_files: derived_var_files,
              non_interactive: non_interactive)
        end
      end
    end
  end
end