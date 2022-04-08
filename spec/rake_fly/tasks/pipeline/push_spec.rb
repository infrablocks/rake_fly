# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::Pipeline::Push do
  include_context 'rake'

  before do
    namespace :fly do
      task :ensure
    end
  end

  it 'adds a push task in the namespace in which it is created' do
    namespace :pipeline do
      described_class.define(
        target: 'supercorp-ci',
        pipeline: 'supercorp-something'
      )
    end

    expect(Rake.application)
      .to(have_task_defined('pipeline:push'))
  end

  it 'gives the push task a description' do
    namespace :pipeline do
      described_class.define(
        target: 'supercorp-ci',
        pipeline: 'supercorp-something'
      )
    end

    expect(Rake::Task['pipeline:push'].full_comment)
      .to(eq('Push pipeline supercorp-something to target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      described_class.define(
        name: 'prepare',
        target: 'supercorp-ci',
        pipeline: 'supercorp-something'
      )
    end

    expect(Rake.application)
      .to(have_task_defined('pipeline:prepare'))
  end

  it 'allows multiple push tasks to be declared' do
    namespace :something1 do
      described_class.define(
        target: 'supercorp-ci',
        pipeline: 'supercorp-something1'
      )
    end

    namespace :something2 do
      described_class.define(
        target: 'supercorp-ci',
        pipeline: 'supercorp-something2'
      )
    end

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[something1:push
               something2:push]
          ))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = %i[deployment_identifier region]

    namespace :pipeline do
      described_class.define(
        argument_names: argument_names,
        target: 'supercorp-ci',
        pipeline: 'supercorp-something'
      )
    end

    expect(Rake::Task['pipeline:push'].arg_names)
      .to(eq(argument_names))
  end

  # rubocop:disable RSpec/MultipleExpectations
  it 'invokes the set, get and unpause tasks ' \
     'in order' do
    namespace :pipeline do
      described_class.define(
        argument_names: [:thing],
        target: 'supercorp-ci',
        pipeline: 'supercorp-something'
      )

      task :set
      task :get
      task :unpause
    end

    push_task = Rake::Task['pipeline:push']

    allow(Rake::Task['pipeline:set']).to(receive(:invoke))
    allow(Rake::Task['pipeline:get']).to(receive(:invoke))
    allow(Rake::Task['pipeline:unpause']).to(receive(:invoke))

    push_task.invoke('important_arg')

    expect(Rake::Task['pipeline:set'])
      .to(have_received(:invoke)
            .with('important_arg')
            .ordered)
    expect(Rake::Task['pipeline:get'])
      .to(have_received(:invoke)
            .with('important_arg')
            .ordered)
    expect(Rake::Task['pipeline:unpause'])
      .to(have_received(:invoke)
            .with('important_arg')
            .ordered)
  end
  # rubocop:enable RSpec/MultipleExpectations

  # rubocop:disable RSpec/MultipleExpectations
  it 'invokes the set, get and unpause tasks using custom names when present' do
    namespace :pipeline do
      described_class.define(
        name: :push,
        argument_names: [:thing],
        set_task_name: :send,
        get_task_name: :fetch,
        unpause_task_name: :resume,
        target: 'supercorp-ci',
        pipeline: 'supercorp-something1'
      )

      task :send
      task :fetch
      task :resume
    end

    push_task = Rake::Task['pipeline:push']

    allow(Rake::Task['pipeline:send']).to(receive(:invoke))
    allow(Rake::Task['pipeline:fetch']).to(receive(:invoke))
    allow(Rake::Task['pipeline:resume']).to(receive(:invoke))

    push_task.invoke('important_arg')

    expect(Rake::Task['pipeline:send'])
      .to(have_received(:invoke)
            .with('important_arg')
            .ordered)
    expect(Rake::Task['pipeline:fetch'])
      .to(have_received(:invoke)
            .with('important_arg')
            .ordered)
    expect(Rake::Task['pipeline:resume'])
      .to(have_received(:invoke)
            .with('important_arg')
            .ordered)
  end
  # rubocop:enable RSpec/MultipleExpectations

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
