# frozen_string_literal: true

require 'spec_helper'

describe RakeFly::TaskSets::Authentication do
  include_context 'rake'

  it 'adds all authentication tasks in the provided namespace ' \
     'when supplied' do
    described_class.define(
      namespace: :authentication,
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci'
    )

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[authentication:login
               authentication:ensure]
          ))
  end

  it 'adds all authentication tasks in the root namespace when none supplied' do
    described_class.define(
      concourse_url: 'https://concourse.example.com',
      target: 'supercorp-ci'
    )

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[login
               ensure]
          ))
  end

  describe 'login task' do
    it 'configures with target' do
      target = 'supercorp-ci'

      namespace :authentication do
        described_class.define(
          target:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.target).to(eq(target))
    end

    it 'configures with concourse URL' do
      concourse_url = 'https://concourse.example.com'

      namespace :authentication do
        described_class.define(
          concourse_url:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.concourse_url).to(eq(concourse_url))
    end

    it 'uses a home directory of ENV["HOME"] by default' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'
      home_directory = '/some/path/to/home'

      ENV['HOME'] = home_directory

      namespace :authentication do
        described_class.define(
          concourse_url:,
          target:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided home directory when supplied' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'
      home_directory = '/tmp/fly'

      namespace :authentication do
        described_class.define(
          target:,
          concourse_url:,
          home_directory:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses a team of main by default' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'

      namespace :authentication do
        described_class.define(
          concourse_url:,
          target:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.team).to(eq('main'))
    end

    it 'uses the default backend when not supplied' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'
      backend = RakeFly::Tasks::Authentication::Login::ApiBackend

      namespace :authentication do
        described_class.define(
          target:,
          concourse_url:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.backend).to(eq(backend))
    end

    it 'uses the provided backend when supplied' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'
      backend = RakeFly::Tasks::Authentication::Login::FlyBackend

      namespace :authentication do
        described_class.define(
          target:,
          concourse_url:,
          backend:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.backend).to(eq(backend))
    end

    it 'uses the provided team when supplied' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'
      team = 'supercorp-team'

      namespace :authentication do
        described_class.define(
          target:,
          concourse_url:,
          team:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.team).to(eq(team))
    end

    it 'has no username by default' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'

      namespace :authentication do
        described_class.define(
          target:,
          concourse_url:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.username).to(be_nil)
    end

    it 'uses the provided username when supplied' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'
      username = 'supercorp-user'

      namespace :authentication do
        described_class.define(
          target:,
          concourse_url:,
          username:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.username).to(eq(username))
    end

    it 'has no password by default' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'

      namespace :authentication do
        described_class.define(
          target:,
          concourse_url:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.password).to(be_nil)
    end

    it 'uses the provided password when supplied' do
      target = 'supercorp-ci'
      concourse_url = 'https://concourse.example.com'
      password = 'super-secret'

      namespace :authentication do
        described_class.define(
          target:,
          concourse_url:,
          password:
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.creator.password).to(eq(password))
    end

    it 'uses the provided argument names when present' do
      argument_names = %i[argument names]

      namespace :authentication do
        described_class.define(
          argument_names:,

          target: 'supercorp-ci',
          concourse_url: 'https://concourse.example.com'
        )
      end

      rake_task = Rake::Task['authentication:login']

      expect(rake_task.arg_names).to(eq(argument_names))
    end

    it 'uses the provided login task name when present' do
      namespace :authentication do
        described_class.define(
          target: 'supercorp-ci',
          concourse_url: 'https://concourse.example.com',

          login_task_name: :authenticate
        )
      end

      expect(Rake.application)
        .to(have_task_defined('authentication:authenticate'))
    end
  end

  describe 'ensure task' do
    it 'configures with target' do
      target = 'supercorp-ci'

      namespace :authentication do
        described_class.define(target:)
      end

      rake_task = Rake::Task['authentication:ensure']

      expect(rake_task.creator.target).to(eq(target))
    end

    it 'uses a home directory of ENV["HOME"] by default' do
      target = 'supercorp-ci'
      home_directory = '/some/path/to/home'

      ENV['HOME'] = home_directory

      namespace :authentication do
        described_class.define(
          target:
        )
      end

      rake_task = Rake::Task['authentication:ensure']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided home directory when supplied' do
      target = 'supercorp-ci'
      home_directory = '/tmp/fly'

      namespace :authentication do
        described_class.define(
          target:,
          home_directory:
        )
      end

      rake_task = Rake::Task['authentication:ensure']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided argument names when present' do
      argument_names = %i[argument names]

      namespace :authentication do
        described_class.define(
          argument_names:,

          target: 'supercorp-ci'
        )
      end

      rake_task = Rake::Task['authentication:ensure']

      expect(rake_task.arg_names).to(eq(argument_names))
    end

    it 'uses the provided login task name when present' do
      namespace :authentication do
        described_class.define(
          target: 'supercorp-ci',
          concourse_url: 'https://concourse.example.com',

          login_task_name: :authenticate
        )
      end

      rake_task = Rake::Task['authentication:ensure']

      expect(rake_task.creator.login_task_name).to(eq(:authenticate))
    end
  end
end
