require 'spec_helper'

describe RakeFly::TaskSets::Pipeline do
  include_context :rake

  context 'get pipeline task' do
    it 'configures with target and pipeline' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = 'ci/pipeline.yml'
        end
      end
      
      rake_task = Rake::Task["something:get_pipeline"]
      
      expect(rake_task.creator.target).to(eq(target))
      expect(rake_task.creator.pipeline).to(eq(pipeline))
    end

    it 'uses the provided get pipeline task name when present' do
      namespace :something do
        subject.define do |t|
          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'

          t.get_pipeline_task_name = :get
        end
      end
      
      expect(Rake::Task.task_defined?("something:get")).to(be(true))
    end

    it 'uses the provided argument names when present' do
      argument_names = [:argument, :names]

      namespace :something do
        subject.define do |t|
          t.argument_names = argument_names

          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'
        end
      end
      
      rake_task = Rake::Task["something:get_pipeline"]
      
      expect(rake_task.arg_names).to(eq(argument_names))
    end
  end

  context 'set pipeline task' do
    it 'configures with target, pipeline and config' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
        end
      end

      rake_task = Rake::Task["something:set_pipeline"]

      expect(rake_task.creator.target).to(eq(target))
      expect(rake_task.creator.pipeline).to(eq(pipeline))
      expect(rake_task.creator.config).to(eq(config))
    end

    it 'passes vars when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      vars = {
          key1: 'value1',
          key2: 'value2'
      }

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
          t.vars = vars
        end
      end

      rake_task = Rake::Task["something:set_pipeline"]

      expect(rake_task.creator.vars).to(eq(vars))
    end

    it 'passes nil for vars when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
        end
      end

      rake_task = Rake::Task["something:set_pipeline"]

      expect(rake_task.creator.vars).to(be_nil)
    end

    it 'passes var files when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      var_files = ['config/variables.yml']

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
          t.var_files = var_files
        end
      end

      rake_task = Rake::Task["something:set_pipeline"]

      expect(rake_task.creator.var_files).to(eq(var_files))
    end

    it 'passes nil for var files when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
        end
      end

      rake_task = Rake::Task["something:set_pipeline"]

      expect(rake_task.creator.var_files).to(be_nil)
    end

    it 'passes value for non interactive when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'
      non_interactive = true

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
          t.non_interactive = non_interactive
        end
      end

      rake_task = Rake::Task["something:set_pipeline"]

      expect(rake_task.creator.non_interactive).to(eq(non_interactive))
    end

    it 'passes nil for non interactive when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
        end
      end

      rake_task = Rake::Task["something:set_pipeline"]

      expect(rake_task.creator.non_interactive).to(be_nil)
    end

    it 'uses the provided set pipeline task name when present' do
      namespace :something do
        subject.define do |t|
          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'

          t.set_pipeline_task_name = :set
        end
      end

      expect(Rake::Task.task_defined?("something:set")).to(be(true))
    end

    it 'uses the provided argument names when present' do
      argument_names = [:argument, :names]

      namespace :something do
        subject.define do |t|
          t.argument_names = argument_names

          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'
        end
      end

      rake_task = Rake::Task["something:set_pipeline"]

      expect(rake_task.arg_names).to(eq(argument_names))
    end
  end

  context 'unpause pipeline task' do
    it 'configures with target and pipeline' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = 'ci/pipeline.yml'
        end
      end

      rake_task = Rake::Task["something:unpause_pipeline"]

      expect(rake_task.creator.target).to(eq(target))
      expect(rake_task.creator.pipeline).to(eq(pipeline))
    end

    it 'uses the provided unpause pipeline task name when present' do
      namespace :something do
        subject.define do |t|
          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'

          t.unpause_pipeline_task_name = :unpause
        end
      end

      expect(Rake::Task.task_defined?("something:unpause")).to(be(true))
    end

    it 'uses the provided argument names when present' do
      argument_names = [:argument, :names]

      namespace :something do
        subject.define do |t|
          t.argument_names = argument_names

          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'
        end
      end

      rake_task = Rake::Task["something:unpause_pipeline"]

      expect(rake_task.arg_names).to(eq(argument_names))
    end
  end

  context 'push pipeline task' do
    it 'configures with target and pipeline' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'

      namespace :something do
        subject.define do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = 'ci/pipeline.yml'
        end
      end

      rake_task = Rake::Task["something:push_pipeline"]

      expect(rake_task.creator.target).to(eq(target))
      expect(rake_task.creator.pipeline).to(eq(pipeline))
    end

    it 'uses the provided push pipeline task name when present' do
      namespace :something do
        subject.define do |t|
          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'

          t.push_pipeline_task_name = :push
        end
      end

      expect(Rake::Task.task_defined?("something:push")).to(be(true))
    end

    it 'uses the provided get, set and unpause pipeline task names ' +
        'when present' do
      namespace :something do
        subject.define do |t|
          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'

          t.get_pipeline_task_name = :get
          t.set_pipeline_task_name = :set
          t.unpause_pipeline_task_name = :unpause
        end
      end

      rake_task = Rake::Task["something:push_pipeline"]

      expect(rake_task.creator.get_pipeline_task_name).to(eq(:get))
      expect(rake_task.creator.set_pipeline_task_name).to(eq(:set))
      expect(rake_task.creator.unpause_pipeline_task_name).to(eq(:unpause))
    end

    it 'uses the provided argument names when present' do
      argument_names = [:argument, :names]

      namespace :something do
        subject.define do |t|
          t.argument_names = argument_names

          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'
        end
      end

      rake_task = Rake::Task["something:push_pipeline"]

      expect(rake_task.arg_names).to(eq(argument_names))
    end
  end
end
