
require 'ruby_fly'
require_relative '../tasklib'

module RakeFly
  module Tasks
    class PushPipeline < TaskLib
      parameter :name, :default => :push_pipeline
      parameter :argument_names, :default => []

      parameter :target, :required => true
      parameter :pipeline, :required => true
      parameter :config, :required => true

      parameter :vars
      parameter :var_files
      parameter :non_interactive

      parameter :get_pipeline_task_name, :default => :get_pipeline
      parameter :set_pipeline_task_name, :default => :set_pipeline
      parameter :unpause_pipeline_task_name, :default => :unpause_pipeline

      def process_arguments(args)
        self.name = args[0] if args[0]
      end

      def define
        GetPipeline.new(get_pipeline_task_name) do |t|
          t.argument_names = argument_names
          t.target = target
          t.pipeline = pipeline
        end
        SetPipeline.new(set_pipeline_task_name) do |t|
          t.argument_names = argument_names
          t.target = target
          t.pipeline = pipeline
          t.config = config
          t.vars = vars
          t.var_files = var_files
          t.non_interactive = non_interactive
        end
        UnpausePipeline.new(unpause_pipeline_task_name) do |t|
          t.argument_names = argument_names
          t.target = target
          t.pipeline = pipeline
        end

        desc "Push pipeline #{pipeline} to target #{target}"
        task name => [
            scoped_task_name(set_pipeline_task_name),
            scoped_task_name(get_pipeline_task_name),
            scoped_task_name(unpause_pipeline_task_name)
        ]
      end

      private

      def scoped_task_name(task_name)
        Rake.application.current_scope.path_with_task_name(task_name)
      end
    end
  end
end