require 'spec_helper'
require 'fileutils'

describe RakeFly::TaskSets::Project do
  include_context :rake

  def define_tasks(opts = {}, &block)
    subject.define({
        concourse_url: 'https://concourse.example.com',
        pipeline: 'some-pipeline',
        config: 'ci/pipeline.yml'
    }.merge(opts), &block)
  end

  it 'adds all tasks in the provided namespace when supplied' do
    define_tasks(namespace: :ci)

    expect(Rake::Task.task_defined?('ci:authentication:login'))
        .to(be(true))
    expect(Rake::Task.task_defined?('ci:authentication:ensure'))
        .to(be(true))
    expect(Rake::Task.task_defined?('ci:pipeline:get'))
        .to(be(true))
    expect(Rake::Task.task_defined?('ci:pipeline:set'))
        .to(be(true))
    expect(Rake::Task.task_defined?('ci:pipeline:unpause'))
        .to(be(true))
    expect(Rake::Task.task_defined?('ci:pipeline:push'))
        .to(be(true))
    expect(Rake::Task.task_defined?('ci:pipeline:destroy'))
        .to(be(true))
  end

  it 'adds all tasks in the root namespace when none supplied' do
    define_tasks

    expect(Rake::Task.task_defined?('authentication:login'))
        .to(be(true))
    expect(Rake::Task.task_defined?('authentication:ensure'))
        .to(be(true))
    expect(Rake::Task.task_defined?('pipeline:get'))
        .to(be(true))
    expect(Rake::Task.task_defined?('pipeline:set'))
        .to(be(true))
    expect(Rake::Task.task_defined?('pipeline:unpause'))
        .to(be(true))
    expect(Rake::Task.task_defined?('pipeline:push'))
        .to(be(true))
    expect(Rake::Task.task_defined?('pipeline:destroy'))
        .to(be(true))
  end

  context 'authentication' do
    it 'adds all authentication tasks in the provided namespace ' +
        'when supplied' do
      define_tasks(authentication_namespace: :auth)

      expect(Rake::Task.task_defined?(
          'auth:login'))
          .to(be(true))
      expect(Rake::Task.task_defined?(
          'auth:ensure'))
          .to(be(true))
    end

    it 'adds all authentication tasks in the authentication namespace ' +
        'when none supplied' do
      define_tasks

      expect(Rake::Task.task_defined?(
          'authentication:login'))
          .to(be(true))
      expect(Rake::Task.task_defined?(
          'authentication:ensure'))
          .to(be(true))
    end

    context 'login task' do
      it 'configures with concourse URL' do
        concourse_url = "https://concourse.example.com"

        define_tasks(concourse_url: concourse_url)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.concourse_url).to(eq(concourse_url))
      end

      it 'uses a home directory of ENV["HOME"] by default' do
        concourse_url = "https://concourse.example.com"
        home_directory = "/some/path/to/home"

        ENV["HOME"] = home_directory

        define_tasks(concourse_url: concourse_url)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided home directory when supplied' do
        concourse_url = "https://concourse.example.com"
        home_directory = "/tmp/fly"

        define_tasks(
            concourse_url: concourse_url,
            home_directory: home_directory)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the team as the target name by default' do
        concourse_url = "https://concourse.example.com"
        team = "supercorp"

        define_tasks(
            concourse_url: concourse_url,
            team: team)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.target).to(eq(team))
      end

      it 'uses the provided target when supplied' do
        concourse_url = "https://concourse.example.com"
        target = 'supercorp-ci'

        define_tasks(
            concourse_url: concourse_url,
            target: target)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.target).to(eq(target))
      end

      it 'uses a team of main by default' do
        concourse_url = "https://concourse.example.com"

        define_tasks(concourse_url: concourse_url)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.team).to(eq('main'))
      end

      it 'uses the provided team when supplied' do
        concourse_url = "https://concourse.example.com"
        team = 'supercorp-team'

        define_tasks(
            concourse_url: concourse_url,
            team: team)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.team).to(eq(team))
      end

      it 'has no username by default' do
        concourse_url = "https://concourse.example.com"

        define_tasks(concourse_url: concourse_url)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.username).to(be_nil)
      end

      it 'uses the provided username when supplied' do
        concourse_url = "https://concourse.example.com"
        username = 'supercorp-user'

        define_tasks(
            concourse_url: concourse_url,
            username: username)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.username).to(eq(username))
      end

      it 'has no password by default' do
        concourse_url = "https://concourse.example.com"

        define_tasks(
            concourse_url: concourse_url)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.password).to(be_nil)
      end

      it 'uses the provided username when supplied' do
        concourse_url = "https://concourse.example.com"
        password = 'super-secret'

        define_tasks(
            concourse_url: concourse_url,
            password: password)

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.creator.password).to(eq(password))
      end

      it 'uses the provided argument names when present' do
        argument_names = [:argument, :names]

        define_tasks(
            argument_names: argument_names,

            concourse_url: "https://concourse.example.com")

        rake_task = Rake::Task["authentication:login"]

        expect(rake_task.arg_names).to(eq(argument_names))
      end

      it 'uses the provided login task name when present' do
        define_tasks(
            concourse_url: "https://concourse.example.com",

            authentication_login_task_name: :authenticate)

        expect(Rake::Task.task_defined?("authentication:authenticate"))
            .to(be(true))
      end
    end

    context 'ensure task' do
      it 'uses the team as the target name by default' do
        team = 'supercorp'

        define_tasks(team: team)

        rake_task = Rake::Task["authentication:ensure"]

        expect(rake_task.creator.target).to(eq(team))
      end

      it 'uses a home directory of ENV["HOME"] by default' do
        home_directory = "/some/path/to/home"

        ENV["HOME"] = home_directory

        define_tasks

        rake_task = Rake::Task["authentication:ensure"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided home directory when supplied' do
        home_directory = "/tmp/fly"

        define_tasks(
            home_directory: home_directory)

        rake_task = Rake::Task["authentication:ensure"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided argument names when present' do
        argument_names = [:argument, :names]

        define_tasks(
            argument_names: argument_names)

        rake_task = Rake::Task["authentication:ensure"]

        expect(rake_task.arg_names).to(eq(argument_names))
      end

      it 'uses the provided login task name when present' do
        define_tasks(
            concourse_url: "https://concourse.example.com",

            authentication_login_task_name: :authenticate)

        rake_task = Rake::Task["authentication:ensure"]

        expect(rake_task.creator.login_task_name).to(eq(:authenticate))
      end
    end
  end

  context "pipeline" do
    it 'adds all pipeline tasks in the provided namespace ' +
        'when supplied' do
      define_tasks(pipeline_namespace: :deployment)

      expect(Rake::Task.task_defined?('deployment:get'))
          .to(be(true))
      expect(Rake::Task.task_defined?('deployment:set'))
          .to(be(true))
      expect(Rake::Task.task_defined?('deployment:unpause'))
          .to(be(true))
      expect(Rake::Task.task_defined?('deployment:push'))
          .to(be(true))
      expect(Rake::Task.task_defined?('deployment:destroy'))
          .to(be(true))
    end

    it 'adds all pipeline tasks in the pipeline namespace when none supplied' do
      define_tasks

      expect(Rake::Task.task_defined?('pipeline:get'))
          .to(be(true))
      expect(Rake::Task.task_defined?('pipeline:set'))
          .to(be(true))
      expect(Rake::Task.task_defined?('pipeline:unpause'))
          .to(be(true))
      expect(Rake::Task.task_defined?('pipeline:push'))
          .to(be(true))
      expect(Rake::Task.task_defined?('pipeline:destroy'))
          .to(be(true))
    end

    context 'get task' do
      it 'configures with pipeline' do
        pipeline = 'supercorp-something'

        define_tasks(
            pipeline: pipeline)

        rake_task = Rake::Task["pipeline:get"]

        expect(rake_task.creator.pipeline).to(eq(pipeline))
      end

      it 'uses the team as the target name by default' do
        team = "supercorp"

        define_tasks(team: team)

        rake_task = Rake::Task["pipeline:get"]

        expect(rake_task.creator.target).to(eq(team))
      end

      it 'uses the provided target when supplied' do
        target = 'supercorp-ci'

        define_tasks(target: target)

        rake_task = Rake::Task["pipeline:get"]

        expect(rake_task.creator.target).to(eq(target))
      end

      it 'uses a home directory of ENV["HOME"] by default' do
        pipeline = 'supercorp-something'
        home_directory = "/some/path/to/home"

        ENV["HOME"] = home_directory

        define_tasks

        rake_task = Rake::Task["pipeline:get"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided home directory when supplied' do
        pipeline = 'supercorp-something'
        home_directory = "/tmp/fly"

        define_tasks(
            home_directory: home_directory)

        rake_task = Rake::Task["pipeline:get"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided get task name when present' do
        define_tasks(
            pipeline_get_task_name: :fetch)

        expect(Rake::Task.task_defined?("pipeline:fetch"))
            .to(be(true))
      end

      it 'uses the provided argument names when present' do
        argument_names = [:argument, :names]

        define_tasks(argument_names: argument_names)

        rake_task = Rake::Task["pipeline:get"]

        expect(rake_task.arg_names).to(eq(argument_names))
      end
    end

    context 'set task' do
      it 'configures with pipeline and config' do
        pipeline = 'supercorp-something'
        config = 'ci/pipeline.yml'

        define_tasks(
            pipeline: pipeline,
            config: config)

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.pipeline).to(eq(pipeline))
        expect(rake_task.creator.config).to(eq(config))
      end

      it 'uses the team as the target name by default' do
        team = "supercorp"

        define_tasks(team: team)

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.target).to(eq(team))
      end

      it 'uses the provided target when supplied' do
        target = 'supercorp-ci'

        define_tasks(target: target)

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.target).to(eq(target))
      end

      it 'uses a home directory of ENV["HOME"] by default' do
        home_directory = "/some/path/to/home"

        ENV["HOME"] = home_directory

        define_tasks

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided home directory when supplied' do
        home_directory = "build/fly"

        define_tasks(home_directory: home_directory)

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'passes vars when available' do
        vars = {
            key1: 'value1',
            key2: 'value2'
        }

        define_tasks(vars: vars)

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.vars).to(eq(vars))
      end

      it 'passes nil for vars when not available' do
        define_tasks

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.vars).to(be_nil)
      end

      it 'passes var files when available' do
        var_files = ['config/variables.yml']

        define_tasks(var_files: var_files)

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.var_files).to(eq(var_files))
      end

      it 'passes nil for var files when not available' do
        define_tasks

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.var_files).to(be_nil)
      end

      it 'passes value for non interactive when available' do
        non_interactive = true

        define_tasks(non_interactive: non_interactive)

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.non_interactive).to(eq(non_interactive))
      end

      it 'passes nil for non interactive when not available' do
        define_tasks

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.non_interactive).to(be_nil)
      end

      it 'passes value for team when available' do
        team = 'supercorp-team'

        define_tasks(team: team)

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.team).to(eq(team))
      end

      it 'passes main for team when not available' do
        define_tasks

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.creator.team).to(eq('main'))
      end

      it 'uses the provided set pipeline task name when present' do
        define_tasks(pipeline_set_task_name: :send)

        expect(Rake::Task.task_defined?("pipeline:send"))
            .to(be(true))
      end

      it 'uses the provided argument names when present' do
        argument_names = [:argument, :names]

        define_tasks(
            argument_names: argument_names)

        rake_task = Rake::Task["pipeline:set"]

        expect(rake_task.arg_names).to(eq(argument_names))
      end
    end

    context 'unpause task' do
      it 'configures with pipeline' do
        pipeline = 'supercorp-something'

        define_tasks(pipeline: pipeline)

        rake_task = Rake::Task["pipeline:unpause"]

        expect(rake_task.creator.pipeline).to(eq(pipeline))
      end

      it 'uses a home directory of ENV["HOME"] by default' do
        home_directory = "/some/path/to/home"

        ENV["HOME"] = home_directory

        define_tasks

        rake_task = Rake::Task["pipeline:unpause"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided home directory when supplied' do
        home_directory = "build/fly"

        define_tasks(home_directory: home_directory)

        rake_task = Rake::Task["pipeline:unpause"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided unpause pipeline task name when present' do
        define_tasks(
            pipeline_unpause_task_name: :resume)

        expect(Rake::Task.task_defined?("pipeline:resume"))
            .to(be(true))
      end

      it 'uses the provided argument names when present' do
        argument_names = [:argument, :names]

        define_tasks(argument_names: argument_names)

        rake_task = Rake::Task["pipeline:unpause"]

        expect(rake_task.arg_names).to(eq(argument_names))
      end

      it 'passes value for team when available' do
        team = 'supercorp-team'

        define_tasks(team: team)

        rake_task = Rake::Task["pipeline:unpause"]

        expect(rake_task.creator.team).to(eq(team))
      end

      it 'passes main for team when not available' do
        define_tasks

        rake_task = Rake::Task["pipeline:unpause"]

        expect(rake_task.creator.team).to(eq('main'))
      end
    end

    context 'push task' do
      it 'configures with pipeline' do
        pipeline = 'supercorp-something'

        define_tasks(pipeline: pipeline)

        rake_task = Rake::Task["pipeline:push"]

        expect(rake_task.creator.pipeline).to(eq(pipeline))
      end

      it 'uses the provided push pipeline task name when present' do
        define_tasks(
            pipeline_push_task_name: :publish)

        expect(Rake::Task.task_defined?("pipeline:publish"))
            .to(be(true))
      end

      it 'uses the provided get, set and unpause pipeline task names ' +
          'when present' do
        define_tasks(
            pipeline_get_task_name: :fetch,
            pipeline_set_task_name: :send,
            pipeline_unpause_task_name: :resume)

        rake_task = Rake::Task["pipeline:push"]

        expect(rake_task.creator.get_task_name).to(eq(:fetch))
        expect(rake_task.creator.set_task_name).to(eq(:send))
        expect(rake_task.creator.unpause_task_name).to(eq(:resume))
      end

      it 'uses the provided argument names when present' do
        argument_names = [:argument, :names]

        define_tasks(argument_names: argument_names)

        rake_task = Rake::Task["pipeline:push"]

        expect(rake_task.arg_names).to(eq(argument_names))
      end
    end

    context 'destroy task' do
      it 'configures with pipeline' do
        pipeline = 'supercorp-something'

        define_tasks(
            pipeline: pipeline)

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.creator.pipeline).to(eq(pipeline))
      end

      it 'uses the team as the target name by default' do
        team = "supercorp"

        define_tasks(team: team)

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.creator.target).to(eq(team))
      end

      it 'uses the provided target when supplied' do
        target = 'supercorp-ci'

        define_tasks(target: target)

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.creator.target).to(eq(target))
      end

      it 'passes value for non interactive when available' do
        non_interactive = true

        define_tasks(non_interactive: non_interactive)

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.creator.non_interactive).to(eq(non_interactive))
      end

      it 'passes nil for non interactive when not available' do
        define_tasks

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.creator.non_interactive).to(be_nil)
      end

      it 'passes value for team when available' do
        team = 'supercorp-team'

        define_tasks(team: team)

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.creator.team).to(eq(team))
      end

      it 'passes main for team when not available' do
        define_tasks

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.creator.team).to(eq('main'))
      end

      it 'uses a home directory of ENV["HOME"] by default' do
        home_directory = "/some/path/to/home"

        ENV["HOME"] = home_directory

        define_tasks

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided home directory when supplied' do
        pipeline = 'supercorp-something'
        home_directory = "/tmp/fly"

        define_tasks(
            home_directory: home_directory)

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.creator.home_directory).to(eq(home_directory))
      end

      it 'uses the provided get task name when present' do
        define_tasks(
            pipeline_destroy_task_name: :delete)

        expect(Rake::Task.task_defined?("pipeline:delete"))
            .to(be(true))
      end

      it 'uses the provided argument names when present' do
        argument_names = [:argument, :names]

        define_tasks(argument_names: argument_names)

        rake_task = Rake::Task["pipeline:destroy"]

        expect(rake_task.arg_names).to(eq(argument_names))
      end
    end
  end
end
