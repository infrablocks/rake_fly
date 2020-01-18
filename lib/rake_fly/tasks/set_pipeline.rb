require 'ruby_fly'
require 'rake_factory'

module RakeFly
  module Tasks
    class SetPipeline < RakeFactory::Task
      default_name :set_pipeline
      default_prerequisites ->(t) { [t.ensure_task_name] }
      default_description ->(t) do
        pipeline = t.pipeline || '<derived>'
        target = t.target || '<derived>'

        "Set pipeline #{pipeline} for target #{target}"
      end

      parameter :target, :required => true
      parameter :pipeline, :required => true
      parameter :config, :required => true

      parameter :vars
      parameter :var_files
      parameter :non_interactive

      parameter :ensure_task_name, :default => :'fly:ensure'

      action do |t|
        puts "Setting pipeline #{t.pipeline} for target #{t.target}..."
        RubyFly.set_pipeline(
            target: t.target,
            pipeline: t.pipeline,
            config: t.config,
            vars: t.vars,
            var_files: t.var_files,
            non_interactive: t.non_interactive)
      end
    end
  end
end
