# frozen_string_literal: true

require 'spec_helper'
require 'concourse'

describe RakeFly::Tasks::Authentication::Ensure do
  include_context 'rake'

  before do
    namespace :fly do
      task :ensure
    end
  end

  def define_task(opts = {}, &block)
    opts = {
      namespace: :authentication,
      additional_tasks: [:login]
    }.merge(opts)

    namespace opts[:namespace] do
      opts[:additional_tasks].each do |t|
        task t
      end

      subject.define(opts, &block)
    end
  end

  it 'adds an ensure task in the namespace in which it is created' do
    define_task do |t|
      t.target = 'supercorp-ci'
    end

    expect(Rake.application)
      .to(have_task_defined('authentication:ensure'))
  end

  it 'gives the ensure task a description' do
    define_task(target: 'supercorp-ci')

    expect(Rake::Task['authentication:ensure'].full_comment)
      .to(eq('Ensure logged in for target supercorp-ci'))
  end

  it 'allows multiple ensure tasks to be declared' do
    define_task(
      namespace: :authenticate1,
      target: 'supercorp-ci'
    )
    define_task(
      namespace: :authenticate2,
      target: 'supercorp-ci'
    )

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[authenticate1:ensure
               authenticate2:ensure]
          ))
  end

  it 'defaults to a home directory of ENV["HOME"]' do
    ENV['HOME'] = '/some/home/directory'

    define_task(target: 'supercorp-ci')

    rake_task = Rake::Task['authentication:ensure']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('/some/home/directory'))
  end

  it 'uses the provided home directory' do
    define_task(
      target: 'supercorp-ci',
      home_directory: 'build/fly'
    )

    rake_task = Rake::Task['authentication:ensure']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('build/fly'))
  end

  it 'creates the provided home directory when it does not exist' do
    stub_dir
    define_task(
      target: 'supercorp-ci',
      home_directory: 'build/fly'
    )

    Rake::Task['authentication:ensure'].invoke

    expect(Dir)
      .to(have_received(:mkdir).with('build/fly'))
  end

  it 'depends on the fly:ensure task by default' do
    define_task do |t|
      t.target = 'supercorp-ci'
    end

    expect(Rake::Task['authentication:ensure'].prerequisite_tasks)
      .to(include(Rake::Task['fly:ensure']))
  end

  it 'depends on the provided fly ensure task if specified' do
    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    define_task(fly_ensure_task_name: 'tools:fly:ensure') do |t|
      t.target = 'supercorp-ci'
    end

    expect(Rake::Task['authentication:ensure'].prerequisite_tasks)
      .to(include(Rake::Task['tools:fly:ensure']))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = %i[deployment_identifier region]

    define_task(argument_names: argument_names) do |t|
      t.target = 'supercorp-ci'
    end

    stub_output
    stub_ruby_fly

    expect(Rake::Task['authentication:ensure'].arg_names)
      .to(eq(argument_names))
  end

  it 'fails if no target is provided' do
    define_task

    stub_output
    stub_ruby_fly

    expect do
      Rake::Task['authentication:ensure'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'does nothing when the target is logged in' do
    target_name = 'supercorp-ci'
    home_directory = '/tmp/fly'

    define_task do |t|
      t.target = target_name
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly
    stub_dir

    allow(RubyFly)
      .to(receive(:status)
            .with(hash_including(
                    target: target_name,
                    environment: {
                      'HOME' => home_directory
                    }
                  ))
            .and_return(:logged_in))
    allow(Rake::Task['authentication:login'])
      .to(receive(:invoke))

    Rake::Task['authentication:ensure'].invoke

    expect(Rake::Task['authentication:login'])
      .not_to(have_received(:invoke))
  end

  it 'invokes login when the target is not logged in' do
    target_name = 'supercorp-ci'
    home_directory = '/tmp/fly'

    define_task do |t|
      t.target = target_name
      t.home_directory = home_directory
    end

    stub_output
    stub_ruby_fly
    stub_dir

    allow(RubyFly)
      .to(receive(:status)
            .with(hash_including(
                    target: target_name,
                    environment: {
                      'HOME' => home_directory
                    }
                  ))
            .and_return(:logged_out))
    allow(Rake::Task['authentication:login'])
      .to(receive(:invoke))

    Rake::Task['authentication:ensure'].invoke

    expect(Rake::Task['authentication:login'])
      .to(have_received(:invoke))
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:status))
  end

  def stub_dir
    allow(Dir).to(receive(:mkdir))
  end
end
