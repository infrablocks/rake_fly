# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::Pipeline::Unpause do
  include_context 'rake'

  before do
    namespace :fly do
      task :ensure
    end

    namespace :authentication do
      task :ensure
    end
  end

  it 'adds a unpause task in the namespace in which it is created' do
    namespace :pipeline do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake.application)
      .to(have_task_defined('pipeline:unpause'))
  end

  it 'gives the unpause task a description' do
    namespace :pipeline do
      described_class.define(
        target: 'supercorp-ci',
        pipeline: 'supercorp-something'
      )
    end

    expect(Rake::Task['pipeline:unpause'].full_comment)
      .to(eq('Unpause pipeline supercorp-something for target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      described_class.define(name: :resume) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
      end
    end

    expect(Rake.application)
      .to(have_task_defined('pipeline:resume'))
  end

  it 'allows multiple unpause tasks to be declared' do
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
            %w[something1:unpause
               something2:unpause]
          ))
  end

  it 'depends on the fly:ensure task by default' do
    namespace :pipeline do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['pipeline:unpause'].prerequisite_tasks)
      .to(include(Rake::Task['fly:ensure']))
  end

  it 'depends on the provided fly ensure task if specified' do
    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    namespace :pipeline do
      described_class.define(fly_ensure_task_name: 'tools:fly:ensure') do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['pipeline:unpause'].prerequisite_tasks)
      .to(include(Rake::Task['tools:fly:ensure']))
  end

  it 'depends on the authentication:ensure task by default' do
    namespace :pipeline do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['pipeline:unpause'].prerequisite_tasks)
      .to(include(Rake::Task['authentication:ensure']))
  end

  it 'depends on the provided authentication ensure task if specified' do
    namespace :auth do
      task :ensure
    end

    namespace :pipeline do
      described_class.define(
        authentication_ensure_task_name: 'auth:ensure'
      ) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['pipeline:unpause'].prerequisite_tasks)
      .to(include(Rake::Task['auth:ensure']))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = %i[deployment_identifier region]

    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    namespace :pipeline do
      described_class.define(argument_names:) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
      end
    end

    expect(Rake::Task['pipeline:unpause'].arg_names)
      .to(eq(argument_names))
  end

  it 'defaults to a home directory of ENV["HOME"]' do
    ENV['HOME'] = '/some/home/directory'

    described_class.define(
      target: 'supercorp-ci',
      pipeline: 'supercorp-something'
    )

    rake_task = Rake::Task['unpause']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('/some/home/directory'))
  end

  it 'uses the provided home directory' do
    described_class.define(
      target: 'supercorp-ci',
      pipeline: 'supercorp-something',
      home_directory: 'build/fly'
    )

    rake_task = Rake::Task['unpause']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('build/fly'))
  end

  it 'unpauses the specific pipeline on the specified target' do
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

    allow(RubyFly).to(receive(:unpause_pipeline))

    Rake::Task['unpause'].invoke

    expect(RubyFly)
      .to(have_received(:unpause_pipeline)
            .with(hash_including(
                    target:,
                    pipeline:,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'derives the target from arguments' do
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

    allow(RubyFly).to(receive(:unpause_pipeline))

    Rake::Task['unpause'].invoke(target)

    expect(RubyFly)
      .to(have_received(:unpause_pipeline)
            .with(hash_including(
                    target:,
                    pipeline:,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'derives the team from arguments' do
    target = 'supercorp-ci'
    team = 'supercorp-team'
    pipeline = 'supercorp-something'
    home_directory = 'build/fly'

    described_class.define(argument_names: [:target]) do |t, args|
      t.target = args.target
      t.team = team
      t.pipeline = pipeline
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:unpause_pipeline))

    Rake::Task['unpause'].invoke(target)

    expect(RubyFly)
      .to(have_received(:unpause_pipeline)
            .with(hash_including(
                    team:,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'derives pipeline from arguments' do
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

    allow(RubyFly).to(receive(:unpause_pipeline))

    Rake::Task['unpause'].invoke(pipeline)

    expect(RubyFly)
      .to(have_received(:unpause_pipeline)
            .with(hash_including(
                    target:,
                    pipeline:,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:unpause_pipeline))
  end
end
