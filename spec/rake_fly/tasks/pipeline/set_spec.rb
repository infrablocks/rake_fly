# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::Pipeline::Set do
  include_context 'rake'

  before do
    namespace :fly do
      task :ensure
    end

    namespace :authentication do
      task :ensure
    end
  end

  it 'adds a set task in the namespace in which it is created' do
    namespace :pipeline do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake.application)
      .to(have_task_defined('pipeline:set'))
  end

  it 'gives the set task a description' do
    namespace :pipeline do
      described_class.define(
        target: 'supercorp-ci',
        pipeline: 'supercorp-something'
      ) do |t|
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:set'].full_comment)
      .to(eq('Set pipeline supercorp-something for target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      described_class.define(name: :set) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:set']).not_to be_nil
  end

  it 'allows multiple set tasks to be declared' do
    namespace :something1 do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something1'
        t.config = 'ci/pipeline.yml'
      end
    end

    namespace :something2 do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[something1:set
               something2:set]
          ))
  end

  it 'depends on the fly:ensure task by default' do
    namespace :pipeline do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:set'].prerequisite_tasks)
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
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:set'].prerequisite_tasks)
      .to(include(Rake::Task['tools:fly:ensure']))
  end

  it 'depends on the authentication:ensure task by default' do
    namespace :pipeline do
      described_class.define do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:set'].prerequisite_tasks)
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
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:set'].prerequisite_tasks)
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
      described_class.define(argument_names: argument_names) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:set'].arg_names)
      .to(eq(argument_names))
  end

  it 'defaults to a home directory of ENV["HOME"]' do
    ENV['HOME'] = '/some/home/directory'

    described_class.define(
      target: 'supercorp-ci',
      pipeline: 'supercorp-something',
      config: 'ci/pipeline.yml'
    )

    rake_task = Rake::Task['set']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('/some/home/directory'))
  end

  it 'uses the provided home directory' do
    described_class.define(
      target: 'supercorp-ci',
      pipeline: 'supercorp-something',
      config: 'ci/pipeline.yml',
      home_directory: 'build/fly'
    )

    rake_task = Rake::Task['set']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('build/fly'))
  end

  it 'sets the specific pipeline and config for the specified target' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    home_directory = 'build/fly'

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(
                    target: target,
                    pipeline: pipeline,
                    config: config,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'derives target from arguments' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    home_directory = 'build/fly'

    described_class.define(argument_names: [:target]) do |t, args|
      t.target = args.target
      t.pipeline = pipeline
      t.config = config
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke(target)

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(
                    target: target,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'derives pipeline from arguments' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    home_directory = 'build/fly'

    described_class.define(argument_names: [:pipeline]) do |t, args|
      t.target = target
      t.pipeline = args.pipeline
      t.config = config
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke(pipeline)

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(
                    target: target,
                    pipeline: pipeline,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'derives config from arguments' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    home_directory = 'build/fly'

    described_class.define(argument_names: [:config]) do |t, args|
      t.target = target
      t.pipeline = pipeline
      t.config = args.config
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke(config)

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(
                    config: config,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'derives team from arguments' do
    target = 'supercorp-ci'
    team = 'supercorp-team-1'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    home_directory = 'build/fly'

    described_class.define(argument_names: [:config]) do |t, args|
      t.target = target
      t.team = team
      t.pipeline = pipeline
      t.config = args.config
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke(config)

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(
                    team: team,
                    environment: {
                      'HOME' => home_directory
                    }
                  )))
  end

  it 'passes the provided vars when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    vars = {
      key1: 'value1',
      key2: 'value2'
    }

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.vars = vars
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(vars: vars)))
  end

  it 'passes nil for vars when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(vars: nil)))
  end

  it 'derives vars from arguments' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    important_var = 'some-value'

    described_class.define(argument_names: [:important_var]) do |t, args|
      t.target = target
      t.pipeline = pipeline
      t.config = config

      t.vars = { the_var: args.important_var }
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke(important_var)

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(
                    vars: { the_var: important_var }
                  )))
  end

  it 'passes the provided var files when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    var_files = %w[config/variables.yml config/secrets.yml]

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.var_files = var_files
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(var_files: var_files)))
  end

  it 'passes nil for var files when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(var_files: nil)))
  end

  it 'derives var files from arguments' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    important_var_file = 'some/file.yml'

    described_class.define(argument_names: [:important_var_file]) do |t, args|
      t.target = target
      t.pipeline = pipeline
      t.config = config

      t.var_files = [args.important_var_file]
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke(important_var_file)

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(
                    var_files: [important_var_file]
                  )))
  end

  it 'passes the provided value for non-interactive when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.non_interactive = true
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(non_interactive: true)))
  end

  it 'passes nil for non-interactive when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    described_class.define do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_output
    stub_ruby_fly

    allow(RubyFly).to(receive(:set_pipeline))

    Rake::Task['set'].invoke

    expect(RubyFly)
      .to(have_received(:set_pipeline)
            .with(hash_including(non_interactive: nil)))
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:set_pipeline))
  end
end
