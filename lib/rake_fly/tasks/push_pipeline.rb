require 'ruby_fly'
require 'rake_factory'

module RakeFly
  module Tasks
    class PushPipeline < RakeFactory::Task
      default_name :push_pipeline
      default_description ->(t) do
        pipeline = t.pipeline || '<derived>'
        target = t.target || '<derived>'

        "Push pipeline #{pipeline} to target #{target}"
      end

      parameter :target, :required => true
      parameter :pipeline, :required => true

      parameter :get_pipeline_task_name, :default => :get_pipeline
      parameter :set_pipeline_task_name, :default => :set_pipeline
      parameter :unpause_pipeline_task_name, :default => :unpause_pipeline

      action do |t, args|
        [
            Rake::Task[t.scope.path_with_task_name(t.set_pipeline_task_name)],
            Rake::Task[t.scope.path_with_task_name(t.get_pipeline_task_name)],
            Rake::Task[t.scope.path_with_task_name(
                t.unpause_pipeline_task_name)]
        ].each do |task|
          task.invoke(*args)
        end
      end
    end
  end
end
