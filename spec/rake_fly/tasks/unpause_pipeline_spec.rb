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
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake::Task['something:unpause_pipeline']).not_to be_nil
  end

  it 'gives the unpause_pipeline task a description' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(rake.last_description)
        .to(eq('Unpause pipeline supercorp-something for target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      subject.new(:unpause) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake::Task['pipeline:unpause']).not_to be_nil
  end

  it 'allows multiple unpause_pipeline tasks to be declared' do
    namespace :something1 do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something1'
      end
    end

    namespace :something2 do
      subject.new do |t|
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
      subject.new do |t|
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
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'

        t.ensure_task = 'tools:fly:ensure'
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
      subject.new do |t|
        t.argument_names = argument_names

        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:unpause_pipeline'].arg_names)
        .to(eq(argument_names))
  end

  it 'gets the specific pipeline from the specified target' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.new do |t|
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

  it 'uses the provided target factory when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.new do |t|
      t.argument_names = [:target]
      t.target = lambda { |args| args.target }
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

  it 'uses the provided pipeline factory when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.new do |t|
      t.argument_names = [:pipeline]
      t.target = target
      t.pipeline = lambda { |args| args.pipeline }
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
