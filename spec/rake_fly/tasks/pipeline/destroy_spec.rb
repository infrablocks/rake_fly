# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::Pipeline::Destroy do
  include_context 'rake'

  before do
    namespace :fly do
      task :ensure
    end

    namespace :authentication do
      task :ensure
    end
  end

  it 'adds a get task in the namespace in which it is created' do
    namespace :pipeline do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake.application)
      .to(have_task_defined('pipeline:destroy'))
  end

  it 'gives the get task a description' do
    namespace :pipeline do
      described_class.define(
        target: 'supercorp-ci',
        pipeline: 'supercorp-something'
      )
    end

    expect(Rake::Task['pipeline:destroy'].full_comment)
      .to(eq('Destroy pipeline supercorp-something for target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      described_class.define(name: :delete) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake.application)
      .to(have_task_defined('pipeline:delete'))
  end

  it 'allows multiple destroy tasks to be declared' do
    namespace :something1 do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something1'
      end
    end

    namespace :something2 do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[something1:destroy
               something2:destroy]
          ))
  end

  it 'depends on the fly:ensure task by default' do
    namespace :something do
      described_class.define do |t|
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
      described_class.define(fly_ensure_task_name: 'tools:fly:ensure') do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:destroy'].prerequisite_tasks)
      .to(include(Rake::Task['tools:fly:ensure']))
  end

  it 'depends on the authentication:ensure task by default' do
    namespace :something do
      described_class.define do |t|
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
      described_class.define(
        authentication_ensure_task_name: 'auth:ensure'
      ) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:destroy'].prerequisite_tasks)
      .to(include(Rake::Task['auth:ensure']))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = %i[deployment_identifier region]

    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    namespace :something do
      described_class.define(argument_names: argument_names) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['something:destroy'].arg_names)
      .to(eq(argument_names))
  end

  it 'defaults to a home directory of ENV["HOME"]' do
    ENV['HOME'] = '/some/home/directory'

    described_class.define(
      target: 'supercorp-ci',
      pipeline: 'supercorp-something'
    )

    rake_task = Rake::Task['destroy']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('/some/home/directory'))
  end

  it 'uses the provided home directory' do
    described_class.define(
      target: 'supercorp-ci',
      pipeline: 'supercorp-something',
      home_directory: 'build/fly'
    )

    rake_task = Rake::Task['destroy']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('build/fly'))
  end

  it 'gets the specific pipeline from the specified target' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    home_directory = 'build/fly'

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:destroy_pipeline))

    Rake::Task['destroy'].invoke

    expect(RubyFly)
      .to(have_received(:destroy_pipeline)
            .with(hash_including(
                    target: target,
                    pipeline: pipeline,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'uses the provided target when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    home_directory = 'build/fly'

    described_class.define(argument_names: [:target]) do |t, args|
      t.target = args.target
      t.pipeline = pipeline
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:destroy_pipeline))

    Rake::Task['destroy'].invoke(target)

    expect(RubyFly)
      .to(have_received(:destroy_pipeline)
            .with(hash_including(
                    target: target,
                    pipeline: pipeline,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'uses the provided pipeline when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    home_directory = 'build/fly'

    described_class.define(argument_names: [:pipeline]) do |t, args|
      t.target = target
      t.pipeline = args.pipeline
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:destroy_pipeline))

    Rake::Task['destroy'].invoke(pipeline)

    expect(RubyFly)
      .to(have_received(:destroy_pipeline)
            .with(hash_including(
                    target: target,
                    pipeline: pipeline,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'passes the provided value for non-interactive when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.non_interactive = true
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:destroy_pipeline))

    Rake::Task['destroy'].invoke

    expect(RubyFly)
      .to(have_received(:destroy_pipeline)
            .with(hash_including(non_interactive: true)))
  end

  it 'passes nil for non-interactive when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:destroy_pipeline))

    Rake::Task['destroy'].invoke

    expect(RubyFly)
      .to(have_received(:destroy_pipeline)
            .with(hash_including(non_interactive: nil)))
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:destroy_pipeline))
  end
end
