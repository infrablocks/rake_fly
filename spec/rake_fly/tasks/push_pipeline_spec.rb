require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::PushPipeline do
  include_context :rake

  before(:each) do
    namespace :fly do
      task :ensure
    end
  end

  context 'get pipeline task' do
    it 'configures with target and pipeline' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'

      get_pipeline_configurer = stubbed_get_pipeline_task

      expect(RakeFly::Tasks::GetPipeline)
          .to(receive(:new).and_yield(get_pipeline_configurer))
      expect(get_pipeline_configurer)
          .to(receive(:target=).with(target))
      expect(get_pipeline_configurer)
          .to(receive(:pipeline=).with(pipeline))

      namespace :something do
        subject.new do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = 'ci/pipeline.yml'
        end
      end
    end

    it 'uses the provided get pipeline task name when present' do
      expect(RakeFly::Tasks::GetPipeline)
          .to(receive(:new).with(:get))

      namespace :something do
        subject.new do |t|
          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'

          t.get_pipeline_task_name = :get
        end
      end
    end
  end

  context 'set pipeline task' do
    it 'configures with target, pipeline and config' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      set_pipeline_configurer = stubbed_set_pipeline_task

      expect(RakeFly::Tasks::SetPipeline)
          .to(receive(:new).and_yield(set_pipeline_configurer))
      expect(set_pipeline_configurer).to(receive(:target=).with(target))
      expect(set_pipeline_configurer).to(receive(:pipeline=).with(pipeline))
      expect(set_pipeline_configurer).to(receive(:config=).with(config))

      namespace :something do
        subject.new do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
        end
      end
    end

    it 'passes vars when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      vars = {
          key1: 'value1',
          key2: 'value2'
      }

      set_pipeline_configurer = stubbed_set_pipeline_task

      expect(RakeFly::Tasks::SetPipeline)
          .to(receive(:new).and_yield(set_pipeline_configurer))
      expect(set_pipeline_configurer).to(receive(:vars=).with(vars))

      namespace :something do
        subject.new do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
          t.vars = vars
        end
      end
    end

    it 'passes nil for vars when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      set_pipeline_configurer = stubbed_set_pipeline_task

      expect(RakeFly::Tasks::SetPipeline)
          .to(receive(:new).and_yield(set_pipeline_configurer))
      expect(set_pipeline_configurer).to(receive(:vars=).with(nil))

      namespace :something do
        subject.new do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
        end
      end
    end

    it 'passes var files when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      var_files = ['config/variables.yml']

      set_pipeline_configurer = stubbed_set_pipeline_task

      expect(RakeFly::Tasks::SetPipeline)
          .to(receive(:new).and_yield(set_pipeline_configurer))
      expect(set_pipeline_configurer).to(receive(:var_files=).with(var_files))

      namespace :something do
        subject.new do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
          t.var_files = var_files
        end
      end
    end

    it 'passes nil for var files when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      set_pipeline_configurer = stubbed_set_pipeline_task

      expect(RakeFly::Tasks::SetPipeline)
          .to(receive(:new).and_yield(set_pipeline_configurer))
      expect(set_pipeline_configurer).to(receive(:var_files=).with(nil))

      namespace :something do
        subject.new do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
        end
      end
    end

    it 'passes value for non interactive when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'
      non_interactive = true

      var_files = ['config/variables.yml']

      set_pipeline_configurer = stubbed_set_pipeline_task

      expect(RakeFly::Tasks::SetPipeline)
          .to(receive(:new).and_yield(set_pipeline_configurer))
      expect(set_pipeline_configurer)
          .to(receive(:non_interactive=).with(non_interactive))

      namespace :something do
        subject.new do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
          t.non_interactive = non_interactive
        end
      end
    end

    it 'passes nil for non interactive when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      set_pipeline_configurer = stubbed_set_pipeline_task

      expect(RakeFly::Tasks::SetPipeline)
          .to(receive(:new).and_yield(set_pipeline_configurer))
      expect(set_pipeline_configurer).to(receive(:non_interactive=).with(nil))

      namespace :something do
        subject.new do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = config
        end
      end
    end

    it 'uses the provided set pipeline task name when present' do
      expect(RakeFly::Tasks::SetPipeline)
          .to(receive(:new).with(:set))

      namespace :something do
        subject.new do |t|
          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'

          t.set_pipeline_task_name = :set
        end
      end
    end
  end

  context 'unpause pipeline task' do
    it 'configures with target and pipeline' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'

      unpause_pipeline_configurer = stubbed_unpause_pipeline_task

      expect(RakeFly::Tasks::UnpausePipeline)
          .to(receive(:new).and_yield(unpause_pipeline_configurer))
      expect(unpause_pipeline_configurer)
          .to(receive(:target=).with(target))
      expect(unpause_pipeline_configurer)
          .to(receive(:pipeline=).with(pipeline))

      namespace :something do
        subject.new do |t|
          t.target = target
          t.pipeline = pipeline
          t.config = 'ci/pipeline.yml'
        end
      end
    end

    it 'uses the provided unpause pipeline task name when present' do
      expect(RakeFly::Tasks::UnpausePipeline)
          .to(receive(:new).with(:unpause))

      namespace :something do
        subject.new do |t|
          t.target = 'supercorp-ci'
          t.pipeline = 'supercorp-something'
          t.config = 'ci/pipeline.yml'

          t.unpause_pipeline_task_name = :unpause
        end
      end
    end
  end

  it 'adds a push_pipeline task in the namespace in which it is created' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['something:push_pipeline']).not_to be_nil
  end

  it 'gives the push_pipeline task a description' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(rake.last_description)
        .to(eq('Push pipeline supercorp-something to target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      subject.new(:push) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:push']).not_to be_nil
  end

  it 'allows multiple push_pipeline tasks to be declared' do
    namespace :something1 do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something1'
        t.config = 'ci/pipeline.yml'
      end
    end

    namespace :something2 do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    something1_push_pipeline = Rake::Task['something1:push_pipeline']
    something2_push_pipeline = Rake::Task['something2:push_pipeline']

    expect(something1_push_pipeline).not_to be_nil
    expect(something2_push_pipeline).not_to be_nil
  end

  it 'invokes the set_pipeline, get_pipeline and unpause_pipeline tasks in order' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['something:push_pipeline'].prerequisite_tasks)
        .to(contain_exactly(
                Rake::Task['something:set_pipeline'],
                Rake::Task['something:get_pipeline'],
                Rake::Task['something:unpause_pipeline'],))
  end

  it 'invokes the set, get and unpause pipeline tasks using custom names when present' do
    namespace :pipeline do
      subject.new do |t|
        t.name = :push

        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'

        t.set_pipeline_task_name = :set
        t.get_pipeline_task_name = :get
        t.unpause_pipeline_task_name = :unpause
      end
    end

    expect(Rake::Task['pipeline:push'].prerequisite_tasks)
        .to(contain_exactly(
                Rake::Task['pipeline:set'],
                Rake::Task['pipeline:get'],
                Rake::Task['pipeline:unpause'],))
  end

  def double_allowing(*messages)
    instance = double
    messages.each do |message|
      allow(instance).to(receive(message))
    end
    instance
  end

  def stubbed_get_pipeline_task
    double_allowing(:target=, :pipeline=)
  end

  def stubbed_set_pipeline_task
    double_allowing(
        :target=, :pipeline=, :config=, :vars=, :var_files=,
        :non_interactive=)
  end

  def stubbed_unpause_pipeline_task
    double_allowing(:target=, :pipeline=)
  end
end
