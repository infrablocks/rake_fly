require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::UnpausePipeline do
  include_context :rake

  before(:each) do
    namespace :fly do
      task :ensure
    end
  end

  it 'adds a unpause_pipeline task in the namespace in which it is created' do
    namespace :something do
      subject.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake::Task['something:unpause_pipeline']).not_to be_nil
  end

  it 'gives the unpause_pipeline task a description' do
    namespace :something do
      subject.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task["something:unpause_pipeline"].full_comment)
        .to(eq('Unpause pipeline supercorp-something for target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      subject.define(name: :unpause) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake::Task['pipeline:unpause']).not_to be_nil
  end

  it 'allows multiple unpause_pipeline tasks to be declared' do
    namespace :something1 do
      subject.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something1'
      end
    end

    namespace :something2 do
      subject.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    something1_unpause_pipeline = Rake::Task['something1:unpause_pipeline']
    something2_unpause_pipeline = Rake::Task['something2:unpause_pipeline']

    expect(something1_unpause_pipeline).not_to be_nil
    expect(something2_unpause_pipeline).not_to be_nil
  end

  it 'depends on the fly:ensure task by default' do
    namespace :something do
      subject.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:unpause_pipeline'].prerequisite_tasks)
        .to(include(Rake::Task['fly:ensure']))
  end

  it 'depends on the provided task if specified' do
    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    namespace :something do
      subject.define(ensure_task_name: 'tools:fly:ensure') do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:unpause_pipeline'].prerequisite_tasks)
        .to(include(Rake::Task['tools:fly:ensure']))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = [:deployment_identifier, :region]

    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    namespace :something do
      subject.define(argument_names: argument_names) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:unpause_pipeline'].arg_names)
        .to(eq(argument_names))
  end

  it 'unpauses the specific pipeline on the specified target' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.define do |t|
      t.target = target
      t.pipeline = pipeline
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:unpause_pipeline)
                .with(hash_including(
                          target: target,
                          pipeline: pipeline)))

    Rake::Task['unpause_pipeline'].invoke
  end

  it 'derives the target from arguments' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.define(argument_names: [:target]) do |t, args|
      t.target = args.target
      t.pipeline = pipeline
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:unpause_pipeline)
                .with(hash_including(
                          target: target,
                          pipeline: pipeline)))

    Rake::Task['unpause_pipeline'].invoke(target)
  end

  it 'derives pipeline from arguments' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.define(argument_names: [:pipeline]) do |t, args|
      t.target = target
      t.pipeline = args.pipeline
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:unpause_pipeline)
                .with(hash_including(
                          target: target,
                          pipeline: pipeline)))

    Rake::Task['unpause_pipeline'].invoke(pipeline)
  end

  def stub_puts
    allow_any_instance_of(Kernel).to(receive(:puts))
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:unpause_pipeline))
  end
end
