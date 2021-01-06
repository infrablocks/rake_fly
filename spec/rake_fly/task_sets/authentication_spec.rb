require 'spec_helper'

describe RakeFly::TaskSets::Authentication do
  include_context :rake

  it 'adds all authentication tasks in the provided namespace ' +
      'when supplied' do
    subject.define(
        namespace: :authentication,
        concourse_url: "https://concourse.example.com",
        target: 'supercorp-ci')

    expect(Rake::Task.task_defined?('authentication:login'))
        .to(be(true))
    expect(Rake::Task.task_defined?('authentication:ensure'))
        .to(be(true))
  end

  it 'adds all authentication tasks in the root namespace when none supplied' do
    subject.define(
        concourse_url: "https://concourse.example.com",
        target: 'supercorp-ci')

    expect(Rake::Task.task_defined?('login')).to(be(true))
    expect(Rake::Task.task_defined?('ensure')).to(be(true))
  end

  context 'login task' do
    it 'configures with target and concourse URL' do
      concourse_url = "https://concourse.example.com"
      target = 'supercorp-ci'

      namespace :authentication do
        subject.define(
            concourse_url: concourse_url,
            target: target)
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.creator.target).to(eq(target))
      expect(rake_task.creator.concourse_url).to(eq(concourse_url))
    end

    it 'uses a home directory of ENV["HOME"] by default' do
      target = 'supercorp-ci'
      concourse_url = "https://concourse.example.com"
      home_directory = "/some/path/to/home"

      ENV["HOME"] = home_directory

      namespace :authentication do
        subject.define(
            concourse_url: concourse_url,
            target: target)
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided home directory when supplied' do
      target = 'supercorp-ci'
      concourse_url = "https://concourse.example.com"
      home_directory = "/tmp/fly"

      namespace :authentication do
        subject.define(
            target: target,
            concourse_url: concourse_url,
            home_directory: home_directory)
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses a team of main by default' do
      target = 'supercorp-ci'
      concourse_url = "https://concourse.example.com"

      namespace :authentication do
        subject.define(
            concourse_url: concourse_url,
            target: target)
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.creator.team).to(eq('main'))
    end

    it 'uses the provided team when supplied' do
      target = 'supercorp-ci'
      concourse_url = "https://concourse.example.com"
      team = 'supercorp-team'

      namespace :authentication do
        subject.define(
            target: target,
            concourse_url: concourse_url,
            team: team)
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.creator.team).to(eq(team))
    end

    it 'has no username by default' do
      target = 'supercorp-ci'
      concourse_url = "https://concourse.example.com"

      namespace :authentication do
        subject.define(
            target: target,
            concourse_url: concourse_url)
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.creator.username).to(be_nil)
    end

    it 'uses the provided username when supplied' do
      target = 'supercorp-ci'
      concourse_url = "https://concourse.example.com"
      username = 'supercorp-user'

      namespace :authentication do
        subject.define(
            target: target,
            concourse_url: concourse_url,
            username: username)
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.creator.username).to(eq(username))
    end

    it 'has no password by default' do
      target = 'supercorp-ci'
      concourse_url = "https://concourse.example.com"

      namespace :authentication do
        subject.define(
            target: target,
            concourse_url: concourse_url)
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.creator.password).to(be_nil)
    end

    it 'uses the provided username when supplied' do
      target = 'supercorp-ci'
      concourse_url = "https://concourse.example.com"
      password = 'super-secret'

      namespace :authentication do
        subject.define(
            target: target,
            concourse_url: concourse_url,
            password: password)
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.creator.password).to(eq(password))
    end

    it 'uses the provided argument names when present' do
      argument_names = [:argument, :names]

      namespace :authentication do
        subject.define(
            argument_names: argument_names,

            target: 'supercorp-ci',
            concourse_url: "https://concourse.example.com")
      end

      rake_task = Rake::Task["authentication:login"]

      expect(rake_task.arg_names).to(eq(argument_names))
    end

    it 'uses the provided login task name when present' do
      namespace :authentication do
        subject.define(
            target: 'supercorp-ci',
            concourse_url: "https://concourse.example.com",

            login_task_name: :authenticate)
      end

      expect(Rake::Task.task_defined?("authentication:authenticate"))
          .to(be(true))
    end
  end

  context 'ensure task' do
    it 'configures with target' do
      target = 'supercorp-ci'

      namespace :authentication do
        subject.define(target: target)
      end

      rake_task = Rake::Task["authentication:ensure"]

      expect(rake_task.creator.target).to(eq(target))
    end

    it 'uses a home directory of ENV["HOME"] by default' do
      target = 'supercorp-ci'
      home_directory = "/some/path/to/home"

      ENV["HOME"] = home_directory

      namespace :authentication do
        subject.define(
            target: target)
      end

      rake_task = Rake::Task["authentication:ensure"]

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided home directory when supplied' do
      target = 'supercorp-ci'
      home_directory = "/tmp/fly"

      namespace :authentication do
        subject.define(
            target: target,
            home_directory: home_directory)
      end

      rake_task = Rake::Task["authentication:ensure"]

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided argument names when present' do
      argument_names = [:argument, :names]

      namespace :authentication do
        subject.define(
            argument_names: argument_names,

            target: 'supercorp-ci')
      end

      rake_task = Rake::Task["authentication:ensure"]

      expect(rake_task.arg_names).to(eq(argument_names))
    end

    it 'uses the provided login task name when present' do
      namespace :authentication do
        subject.define(
            target: 'supercorp-ci',
            concourse_url: "https://concourse.example.com",

            login_task_name: :authenticate)
      end

      rake_task = Rake::Task["authentication:ensure"]

      expect(rake_task.creator.login_task_name).to(eq(:authenticate))
    end
  end
end
