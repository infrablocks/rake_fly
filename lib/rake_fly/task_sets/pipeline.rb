require 'rake_factory'

require_relative '../tasks/get_pipeline'
require_relative '../tasks/set_pipeline'
require_relative '../tasks/unpause_pipeline'

module RakeFly
  module TaskSets
    class Pipeline < RakeFactory::TaskSet
      parameter :argument_names, default: []

      parameter :target, :required => true
      parameter :pipeline, :required => true
      parameter :config, :required => true

      parameter :vars
      parameter :var_files
      parameter :non_interactive

      parameter :get_pipeline_task_name, :default => :get_pipeline
      parameter :set_pipeline_task_name, :default => :set_pipeline
      parameter :unpause_pipeline_task_name, :default => :unpause_pipeline
      parameter :push_pipeline_task_name, :default => :push_pipeline

      task Tasks::GetPipeline, name: ->(ts) { ts.get_pipeline_task_name }
      task Tasks::SetPipeline, name: ->(ts) { ts.set_pipeline_task_name }
      task Tasks::UnpausePipeline,
          name: ->(ts) { ts.unpause_pipeline_task_name }
      task Tasks::PushPipeline, name: ->(ts) { ts.push_pipeline_task_name }
    end
  end
end
