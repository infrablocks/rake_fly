require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::Pipeline::Push do
  include_context :rake

  before(:each) do
    namespace :fly do
      task :ensure
    end
  end

  it 'adds a push task in the namespace in which it is created' do
    namespace :pipeline do
      subject.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task.task_defined?('pipeline:push')).to(be(true))
  end

  it 'gives the push task a description' do
    namespace :pipeline do
      subject.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task["pipeline:push"].full_comment)
        .to(eq('Push pipeline supercorp-something to target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      subject.define(
          name: 'prepare',
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task.task_defined?('pipeline:prepare'))
        .to(be(true))
  end

  it 'allows multiple push tasks to be declared' do
    namespace :something1 do
      subject.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something1')
    end

    namespace :something2 do
      subject.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something2')
    end

    expect(Rake::Task.task_defined?('something1:push'))
        .to(be(true))
    expect(Rake::Task.task_defined?('something2:push'))
        .to(be(true))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = [:deployment_identifier, :region]

    namespace :pipeline do
      subject.define(
          argument_names: argument_names,
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task['pipeline:push'].arg_names)
        .to(eq(argument_names))
  end

  it 'invokes the set, get and unpause tasks ' +
      'in order' do
    namespace :pipeline do
      subject.define(
          argument_names: [:thing],
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')

      task :set
      task :get
      task :unpause
    end

    push_task = Rake::Task['pipeline:push']

    expect(Rake::Task['pipeline:set'])
        .to(receive(:invoke)
            .with('important_arg')
            .ordered)
    expect(Rake::Task['pipeline:get'])
        .to(receive(:invoke)
            .with('important_arg')
            .ordered)
    expect(Rake::Task['pipeline:unpause'])
        .to(receive(:invoke)
            .with('important_arg')
            .ordered)

    push_task.invoke('important_arg')
  end

  it 'invokes the set, get and unpause tasks using custom names when present' do
    namespace :pipeline do
      subject.define(
          name: :push,
          argument_names: [:thing],
          set_task_name: :send,
          get_task_name: :fetch,
          unpause_task_name: :resume,
          target: 'supercorp-ci',
          pipeline: 'supercorp-something1')

      task :send
      task :fetch
      task :resume
    end

    push_task = Rake::Task['pipeline:push']

    expect(Rake::Task['pipeline:send'])
        .to(receive(:invoke)
            .with('important_arg')
            .ordered)
    expect(Rake::Task['pipeline:fetch'])
        .to(receive(:invoke)
            .with('important_arg')
            .ordered)
    expect(Rake::Task['pipeline:resume'])
        .to(receive(:invoke)
            .with('important_arg')
            .ordered)

    push_task.invoke('important_arg')
  end

  def double_allowing(*messages)
    instance = double
    messages.each do |message|
      allow(instance).to(receive(message))
    end
    instance
  end

  def stub_rake_task
    double_allowing(:argument_names=, :target=, :pipeline=)
  end
end
