require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::Pipeline::Destroy do
  include_context :rake

  before(:each) do
    namespace :fly do
      task :ensure
    end

    namespace :authentication do
      task :ensure
    end
  end

  it 'adds a get task in the namespace in which it is created' do
    namespace :pipeline do
      subject.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake::Task['pipeline:destroy']).not_to be_nil
  end

  it 'gives the get task a description' do
    namespace :pipeline do
      subject.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task["pipeline:destroy"].full_comment)
        .to(eq('Destroy pipeline supercorp-something for target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      subject.define(name: :delete) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake::Task['pipeline:delete']).not_to be_nil
  end

  it 'allows multiple destroy tasks to be declared' do
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

    something1_destroy_pipeline = Rake::Task['something1:destroy']
    something2_destroy_pipeline = Rake::Task['something2:destroy']

    expect(something1_destroy_pipeline).not_to be_nil
    expect(something2_destroy_pipeline).not_to be_nil
  end

  it 'depends on the fly:ensure task by default' do
    namespace :something do
      subject.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:destroy'].prerequisite_tasks)
        .to(include(Rake::Task['fly:ensure']))
  end

  it 'depends on the provided fly ensure task if specified' do
    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    namespace :something do
      subject.define(fly_ensure_task_name: 'tools:fly:ensure') do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:destroy'].prerequisite_tasks)
        .to(include(Rake::Task['tools:fly:ensure']))
  end

  it 'depends on the authentication:ensure task by default' do
    namespace :something do
      subject.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:destroy'].prerequisite_tasks)
        .to(include(Rake::Task['authentication:ensure']))
  end

  it 'depends on the provided authentication ensure task if specified' do
    namespace :auth do
      task :ensure
    end

    namespace :something do
      subject.define(
          authentication_ensure_task_name: 'auth:ensure') do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:destroy'].prerequisite_tasks)
        .to(include(Rake::Task['auth:ensure']))
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

    expect(Rake::Task['something:destroy'].arg_names)
        .to(eq(argument_names))
  end

  it 'defaults to a home directory of ENV["HOME"]' do
    ENV["HOME"] = "/some/home/directory"

    subject.define(
        target: 'supercorp-ci',
        pipeline: 'supercorp-something')

    rake_task = Rake::Task['destroy']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('/some/home/directory'))
  end

  it 'uses the provided home directory' do
    subject.define(
        target: 'supercorp-ci',
        pipeline: 'supercorp-something',
        home_directory: 'build/fly')

    rake_task = Rake::Task['destroy']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('build/fly'))
  end

  it 'gets the specific pipeline from the specified target' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    home_directory = 'build/fly'

    subject.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.home_directory = home_directory
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:destroy_pipeline)
            .with(hash_including(
                target: target,
                pipeline: pipeline,
                environment: {
                    "HOME" => home_directory
                })))

    Rake::Task['destroy'].invoke
  end

  it 'uses the provided target when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    home_directory = 'build/fly'

    subject.define(argument_names: [:target]) do |t, args|
      t.target = args.target
      t.pipeline = pipeline
      t.home_directory = home_directory
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:destroy_pipeline)
            .with(hash_including(
                target: target,
                pipeline: pipeline,
                environment: {
                    "HOME" => home_directory
                })))

    Rake::Task['destroy'].invoke(target)
  end

  it 'uses the provided pipeline when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    home_directory = 'build/fly'

    subject.define(argument_names: [:pipeline]) do |t, args|
      t.target = target
      t.pipeline = args.pipeline
      t.home_directory = home_directory
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:destroy_pipeline)
            .with(hash_including(
                target: target,
                pipeline: pipeline,
                environment: {
                    "HOME" => home_directory
                })))

    Rake::Task['destroy'].invoke(pipeline)
  end

  it 'passes the provided value for non-interactive when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.non_interactive = true
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:destroy_pipeline)
            .with(hash_including(non_interactive: true)))

    Rake::Task['destroy'].invoke
  end

  it 'passes nil for non-interactive when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    subject.define do |t|
      t.target = target
      t.pipeline = pipeline
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:destroy_pipeline)
            .with(hash_including(non_interactive: nil)))

    Rake::Task['destroy'].invoke
  end

  def stub_puts
    allow_any_instance_of(Kernel).to(receive(:puts))
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:destroy_pipeline))
  end
end
