# frozen_string_literal: true

require 'spec_helper'
require 'concourse'

describe RakeFly::Tasks::Authentication::Login do
  include_context 'rake'

  before do
    namespace :fly do
      task :ensure
    end
  end

  def define_task(opts = {}, &block)
    opts = { namespace: :authentication, additional_tasks: [] }.merge(opts)

    namespace opts[:namespace] do
      opts[:additional_tasks].each do |t|
        task t
      end

      subject.define(opts, &block)
    end
  end

  it 'adds a login task in the namespace in which it is created' do
    define_task do |t|
      t.concourse_url = 'https://concourse.example.com'
      t.target = 'supercorp-ci'
      t.username = 'some-user'
      t.password = 'super-secure'
    end

    expect(Rake.application)
      .to(have_task_defined('authentication:login'))
  end

  it 'gives the login task a description' do
    define_task(
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci',
      username: 'some-user',
      password: 'super-secure'
    )

    expect(Rake::Task['authentication:login'].full_comment)
      .to(eq('Login to https://concourse.example.com as target supercorp-ci'))
  end

  it 'allows multiple login tasks to be declared' do
    define_task(
      namespace: :authenticate1,
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci',
      username: 'some-user',
      password: 'super-secure'
    )
    define_task(
      namespace: :authenticate2,
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci',
      username: 'some-user',
      password: 'super-secure'
    )

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[authenticate1:login
               authenticate2:login]
          ))
  end

  it 'defaults to the API backend' do
    define_task(
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci',
      username: 'some-user',
      password: 'super-secure'
    )

    rake_task = Rake::Task['authentication:login']
    test_task = rake_task.creator

    expect(test_task.backend)
      .to(eq(RakeFly::Tasks::Authentication::Login::ApiBackend))
  end

  it 'uses the provided backend' do
    define_task(
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci',
      backend: RakeFly::Tasks::Authentication::Login::FlyBackend
    )

    rake_task = Rake::Task['authentication:login']
    test_task = rake_task.creator

    expect(test_task.backend)
      .to(eq(RakeFly::Tasks::Authentication::Login::FlyBackend))
  end

  it 'defaults to the main team' do
    define_task(
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci',
      username: 'some-user',
      password: 'super-secure'
    )

    rake_task = Rake::Task['authentication:login']
    test_task = rake_task.creator

    expect(test_task.team).to(eq('main'))
  end

  it 'uses the provided team' do
    define_task(
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci',
      team: 'supercorp-team',
      username: 'some-user',
      password: 'super-secure'
    )

    rake_task = Rake::Task['authentication:login']
    test_task = rake_task.creator

    expect(test_task.team).to(eq('supercorp-team'))
  end

  it 'defaults to a home directory of ENV["HOME"]' do
    ENV['HOME'] = '/some/home/directory'

    define_task(
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci',
      username: 'some-user',
      password: 'super-secure'
    )

    rake_task = Rake::Task['authentication:login']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('/some/home/directory'))
  end

  it 'uses the provided home directory' do
    define_task(
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci',
      username: 'some-user',
      password: 'super-secure',
      home_directory: 'build/fly'
    )

    rake_task = Rake::Task['authentication:login']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('build/fly'))
  end

  it 'has no dependencies by default' do
    define_task do |t|
      t.concourse_url = 'https://concourse.example.com'
      t.target = 'supercorp-ci'
      t.username = 'some-user'
      t.password = 'super-secure'
    end

    expect(Rake::Task['authentication:login'].prerequisite_tasks)
      .to(be_empty)
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = %i[deployment_identifier region]

    define_task(argument_names: argument_names) do |t|
      t.concourse_url = 'https://concourse.example.com'
      t.target = 'supercorp-ci'
      t.username = 'some-user'
      t.password = 'super-secure'
    end

    expect(Rake::Task['authentication:login'].arg_names)
      .to(eq(argument_names))
  end

  it 'fails if no concourse URL is provided' do
    define_task do |t|
      t.target = 'supercorp-ci'
    end

    stub_output

    expect do
      Rake::Task['authentication:login'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no target is provided' do
    define_task do |t|
      t.concourse_url = 'https://concourse.example.com'
    end

    stub_output

    expect do
      Rake::Task['authentication:login'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  context 'when using the API backend' do
    it 'has no dependencies' do
      define_task(
        backend: RakeFly::Tasks::Authentication::Login::ApiBackend
      ) do |t|
        t.concourse_url = 'https://concourse.example.com'
        t.target = 'supercorp-ci'
        t.username = 'some-user'
        t.password = 'super-secure'
      end

      expect(Rake::Task['authentication:login'].prerequisite_tasks)
        .to(be_empty)
    end

    it 'logs in via the API and stores the credentials in a fly RC file' do
      concourse_url = 'https://concourse.example.com'
      team_name = 'supercorp-team'
      target_name = 'supercorp-ci'
      username = 'some-user'
      password = 'super-secure'
      home_directory = '/tmp/fly'

      define_task(
        backend: RakeFly::Tasks::Authentication::Login::ApiBackend
      ) do |t|
        t.concourse_url = concourse_url
        t.team = team_name
        t.target = target_name
        t.username = username
        t.password = password
        t.home_directory = home_directory
      end

      stub_output

      concourse_client = instance_double(Concourse::Client)
      skymarshal_client =
        instance_double(Concourse::SubClients::SkymarshalClient)
      token = Build::Data.random_token

      allow(Concourse::Client)
        .to(receive(:new)
              .with(hash_including(url: concourse_url))
              .and_return(concourse_client))
      allow(concourse_client)
        .to(receive(:for_skymarshal)
              .and_return(skymarshal_client))
      allow(skymarshal_client)
        .to(receive(:create_token)
              .with(username: username, password: password)
              .and_return(token))

      Rake::Task['authentication:login'].invoke

      targets = RubyFly::RC.load(home: home_directory).targets

      expect(targets).to(eq([RubyFly::RC::Target.new(
        name: target_name.to_sym,
        api: concourse_url,
        team: team_name,
        token: { type: 'bearer', value: token.access_token }
      )]))
    end
  end

  describe 'fly backend' do
    it 'depends on the fly:ensure task when using fly as the backend' do
      define_task(
        backend: RakeFly::Tasks::Authentication::Login::FlyBackend
      ) do |t|
        t.concourse_url = 'https://concourse.example.com'
        t.target = 'supercorp-ci'
      end

      expect(Rake::Task['authentication:login'].prerequisite_tasks)
        .to(include(Rake::Task['fly:ensure']))
    end

    it 'depends on the provided ensure task if specified and using ' \
       'fly as backend' do
      namespace :tools do
        namespace :fly do
          task :ensure
        end
      end

      define_task(
        fly_ensure_task_name: 'tools:fly:ensure',
        backend: RakeFly::Tasks::Authentication::Login::FlyBackend
      ) do |t|
        t.concourse_url = 'https://concourse.example.com'
        t.target = 'supercorp-ci'
      end

      stub_output

      expect(Rake::Task['authentication:login'].prerequisite_tasks)
        .to(include(Rake::Task['tools:fly:ensure']))
    end

    it 'logs in via fly' do
      concourse_url = 'https://concourse.example.com'
      team_name = 'supercorp-team'
      target_name = 'supercorp-ci'
      username = 'some-user'
      password = 'super-secure'
      home_directory = '/tmp/fly'

      define_task(
        backend: RakeFly::Tasks::Authentication::Login::FlyBackend
      ) do |t|
        t.concourse_url = concourse_url
        t.team = team_name
        t.target = target_name
        t.username = username
        t.password = password
        t.home_directory = home_directory
      end

      stub_output
      stub_ruby_fly

      allow(RubyFly).to(receive(:login))

      Rake::Task['authentication:login'].invoke

      expect(RubyFly)
        .to(have_received(:login)
              .with(hash_including(
                      target: target_name,
                      concourse_url: concourse_url,
                      username: username,
                      password: password,
                      team: team_name,
                      environment: {
                        'HOME' => home_directory
                      }
                    )))
    end
  end

  def stub_output
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:login))
  end
end
