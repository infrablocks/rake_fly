require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::GetPipeline do
  include_context :rake

  before(:each) do
    namespace :fly do
      task :ensure
    end
  end

  it 'adds a get_pipeline task in the namespace in which it is created' do
    namespace :something do
      subject.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake::Task['something:get_pipeline']).not_to be_nil
  end

  it 'gives the get_pipeline task a description' do
    namespace :something do
      subject.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task["something:get_pipeline"].full_comment)
        .to(eq('Get pipeline supercorp-something for target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      subject.define(name: :get) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake::Task['pipeline:get']).not_to be_nil
  end

  it 'allows multiple get_pipeline tasks to be declared' do
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

    something1_get_pipeline = Rake::Task['something1:get_pipeline']
    something2_get_pipeline = Rake::Task['something2:get_pipeline']

    expect(something1_get_pipeline).not_to be_nil
    expect(something2_get_pipeline).not_to be_nil
  end

  it 'depends on the fly:ensure task by default' do
    namespace :something do
      subject.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:get_pipeline'].prerequisite_tasks)
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

    expect(Rake::Task['something:get_pipeline'].prerequisite_tasks)
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

    expect(Rake::Task['something:get_pipeline'].arg_names)
        .to(eq(argument_names))
  end

  it 'gets the specific pipeline from the specified target' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.define do |t|
      t.target = target
      t.pipeline = pipeline
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:get_pipeline)
            .with(hash_including(
                target: target,
                pipeline: pipeline)))

    Rake::Task['get_pipeline'].invoke
  end

  it 'uses the provided target factory when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.define(argument_names: [:target]) do |t, args|
      t.target = args.target
      t.pipeline = pipeline
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:get_pipeline)
            .with(hash_including(
                target: target,
                pipeline: pipeline)))

    Rake::Task['get_pipeline'].invoke(target)
  end

  it 'uses the provided pipeline factory when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.define(argument_names: [:pipeline]) do |t, args|
      t.target = target
      t.pipeline = args.pipeline
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:get_pipeline)
            .with(hash_including(
                target: target,
                pipeline: pipeline)))

    Rake::Task['get_pipeline'].invoke(pipeline)
  end

  def stub_puts
    allow_any_instance_of(Kernel).to(receive(:puts))
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:get_pipeline))
  end
end
