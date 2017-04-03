require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::SetPipeline do
  include_context :rake

  before(:each) do
    namespace :fly do
      task :ensure
    end
  end


  it 'adds a set_pipeline task in the namespace in which it is created' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['something:set_pipeline']).not_to be_nil
  end

  it 'gives the set_pipeline task a description' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(rake.last_description)
        .to(eq('Set pipeline supercorp-something for target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      subject.new(:set) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:set']).not_to be_nil
  end

  it 'allows multiple set_pipeline tasks to be declared' do
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

    something1_set_pipeline = Rake::Task['something1:set_pipeline']
    something2_set_pipeline = Rake::Task['something2:set_pipeline']

    expect(something1_set_pipeline).not_to be_nil
    expect(something2_set_pipeline).not_to be_nil
  end

  it 'depends on the fly:ensure task by default' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['something:set_pipeline'].prerequisite_tasks)
        .to(include(Rake::Task['fly:ensure']))
  end

  it 'depends on the provided task if specified' do
    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'

        t.ensure_task = 'tools:fly:ensure'
      end
    end

    expect(Rake::Task['something:set_pipeline'].prerequisite_tasks)
        .to(include(Rake::Task['tools:fly:ensure']))
  end

  it 'sets the specific pipeline and config for the specified target' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(
                          target: target,
                          pipeline: pipeline,
                          config: config)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'passes the provided vars when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    vars = {
        key1: 'value1',
        key2: 'value2'
    }

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.vars = vars
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(vars: vars)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'passes nil for vars when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(vars: nil)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'passes the provided var files when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    var_files = [
        'config/variables.yml',
        'config/secrets.yml'
    ]

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.var_files = var_files
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(var_files: var_files)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'passes nil for var files when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(var_files: nil)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'passes the provided value for non-interactive when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    vars = {
        key1: 'value1',
        key2: 'value2'
    }

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.non_interactive = true
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(non_interactive: true)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'passes nil for non-interactive when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(non_interactive: nil)))

    Rake::Task['set_pipeline'].invoke
  end

  def stub_puts
    allow_any_instance_of(Kernel).to(receive(:puts))
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:set_pipeline))
  end
end
