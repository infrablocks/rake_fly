require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::PushPipeline do
  include_context :rake

  before(:each) do
    namespace :fly do
      task :ensure
    end
  end

  it 'adds a push_pipeline task in the namespace in which it is created' do
    namespace :something do
      subject.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task.task_defined?('something:push_pipeline')).to(be(true))
  end

  it 'gives the push_pipeline task a description' do
    namespace :something do
      subject.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task["something:push_pipeline"].full_comment)
        .to(eq('Push pipeline supercorp-something to target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      subject.define(
          name: 'push',
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task.task_defined?('pipeline:push')).to(be(true))
  end

  it 'allows multiple push_pipeline tasks to be declared' do
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

    expect(Rake::Task.task_defined?('something1:push_pipeline')).to(be(true))
    expect(Rake::Task.task_defined?('something2:push_pipeline')).to(be(true))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = [:deployment_identifier, :region]

    namespace :something do
      subject.define(
          argument_names: argument_names,
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    expect(Rake::Task['something:push_pipeline'].arg_names)
        .to(eq(argument_names))
  end

  it 'invokes the set_pipeline, get_pipeline and unpause_pipeline tasks ' +
      'in order' do
    namespace :something do
      subject.define(
          argument_names: [:thing],
          target: 'supercorp-ci',
          pipeline: 'supercorp-something')
    end

    set_task = stub_rake_task
    get_task = stub_rake_task
    unpause_task = stub_rake_task

    push_task = Rake::Task['something:push_pipeline']

    allow(Rake::Task)
        .to(receive(:[]).with('something:get_pipeline')
                .and_return(get_task))
    allow(Rake::Task)
        .to(receive(:[]).with('something:set_pipeline')
                .and_return(set_task))
    allow(Rake::Task)
        .to(receive(:[]).with('something:unpause_pipeline')
                .and_return(unpause_task))

    expect(set_task).to(receive(:invoke).with('important_arg'))
    expect(get_task).to(receive(:invoke).with('important_arg'))
    expect(unpause_task).to(receive(:invoke).with('important_arg'))

    push_task.invoke('important_arg')
  end

  it 'invokes the set, get and unpause pipeline tasks using custom names when present' do
    namespace :pipeline do
      subject.define(
          name: :push,
          argument_names: [:thing],
          set_pipeline_task_name: :set,
          get_pipeline_task_name: :get,
          unpause_pipeline_task_name: :unpause,
          target: 'supercorp-ci',
          pipeline: 'supercorp-something1')
    end

    set_task = stub_rake_task
    get_task = stub_rake_task
    unpause_task = stub_rake_task

    push_task = Rake::Task['pipeline:push']

    allow(Rake::Task)
        .to(receive(:[]).with('pipeline:get')
                .and_return(get_task))
    allow(Rake::Task)
        .to(receive(:[]).with('pipeline:set')
                .and_return(set_task))
    allow(Rake::Task)
        .to(receive(:[]).with('pipeline:unpause')
                .and_return(unpause_task))

    expect(set_task).to(receive(:invoke).with('important_arg'))
    expect(get_task).to(receive(:invoke).with('important_arg'))
    expect(unpause_task).to(receive(:invoke).with('important_arg'))

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
