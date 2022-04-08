# frozen_string_literal: true

require 'spec_helper'

describe RakeFly::TaskSets::Pipeline do
  include_context 'rake'

  it 'adds all pipeline tasks in the provided namespace ' \
     'when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    described_class.define(
      namespace: :pipeline,
      target: target,
      pipeline: pipeline
    )

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[pipeline:get
               pipeline:set
               pipeline:unpause
               pipeline:push
               pipeline:destroy]
          ))
  end

  it 'adds all pipeline tasks in the root namespace when none supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'

    described_class.define(
      target: target,
      pipeline: pipeline
    )

    expect(Rake.application)
      .to(have_tasks_defined(
            %w[get
               set
               unpause
               push
               destroy]
          ))
  end

  describe 'get task' do
    it 'configures with target' do
      target = 'supercorp-ci'

      namespace :pipeline do
        described_class.define(
          target: target
        )
      end

      rake_task = Rake::Task['pipeline:get']

      expect(rake_task.creator.target).to(eq(target))
    end

    it 'configures with pipeline' do
      pipeline = 'supercorp-something'

      namespace :pipeline do
        described_class.define(
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:get']

      expect(rake_task.creator.pipeline).to(eq(pipeline))
    end

    it 'uses a home directory of ENV["HOME"] by default' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      home_directory = '/some/path/to/home'

      ENV['HOME'] = home_directory

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:get']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided home directory when supplied' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      home_directory = '/tmp/fly'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          home_directory: home_directory
        )
      end

      rake_task = Rake::Task['pipeline:get']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided get task name when present' do
      namespace :pipeline do
        described_class.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something',

          get_task_name: :fetch
        )
      end

      expect(Rake.application)
        .to(have_task_defined('pipeline:fetch'))
    end

    it 'uses the provided argument names when present' do
      argument_names = %i[argument names]

      namespace :pipeline do
        described_class.define(
          argument_names: argument_names,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something'
        )
      end

      rake_task = Rake::Task['pipeline:get']

      expect(rake_task.arg_names).to(eq(argument_names))
    end
  end

  describe 'set task' do
    it 'configures with target' do
      target = 'supercorp-ci'

      namespace :pipeline do
        described_class.define(
          target: target
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.target).to(eq(target))
    end

    it 'configures with pipeline' do
      pipeline = 'supercorp-something'

      namespace :pipeline do
        described_class.define(
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.pipeline).to(eq(pipeline))
    end

    it 'configures with config' do
      config = 'ci/pipeline.yml'

      namespace :pipeline do
        described_class.define(
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.config).to(eq(config))
    end

    it 'uses a home directory of ENV["HOME"] by default' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'
      home_directory = '/some/path/to/home'

      ENV['HOME'] = home_directory

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided home directory when supplied' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'
      home_directory = 'build/fly'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config,
          home_directory: home_directory
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'passes vars when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      vars = {
        key1: 'value1',
        key2: 'value2'
      }

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config,
          vars: vars
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.vars).to(eq(vars))
    end

    it 'passes nil for vars when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.vars).to(be_nil)
    end

    it 'passes var files when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      var_files = ['config/variables.yml']

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config,
          var_files: var_files
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.var_files).to(eq(var_files))
    end

    it 'passes nil for var files when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.var_files).to(be_nil)
    end

    it 'passes value for non interactive when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'
      non_interactive = true

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config,
          non_interactive: non_interactive
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.non_interactive).to(eq(non_interactive))
    end

    it 'passes nil for non interactive when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.non_interactive).to(be_nil)
    end

    it 'passes value for team when available' do
      target = 'supercorp-ci'
      team = 'supercorp-team'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :pipeline do
        described_class.define(
          target: target,
          team: team,
          pipeline: pipeline,
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.team).to(eq(team))
    end

    it 'passes nil for team when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.creator.team).to(be_nil)
    end

    it 'uses the provided set pipeline task name when present' do
      namespace :pipeline do
        described_class.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something',
          config: 'ci/pipeline.yml',

          set_task_name: :send
        )
      end

      expect(Rake.application)
        .to(have_task_defined('pipeline:send'))
    end

    it 'uses the provided argument names when present' do
      argument_names = %i[argument names]

      namespace :pipeline do
        described_class.define(
          argument_names: argument_names,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something',
          config: 'ci/pipeline.yml'
        )
      end

      rake_task = Rake::Task['pipeline:set']

      expect(rake_task.arg_names).to(eq(argument_names))
    end
  end

  describe 'unpause task' do
    it 'configures with target' do
      target = 'supercorp-ci'

      namespace :pipeline do
        described_class.define(
          target: target
        )
      end

      rake_task = Rake::Task['pipeline:unpause']

      expect(rake_task.creator.target).to(eq(target))
    end

    it 'configures with pipeline' do
      pipeline = 'supercorp-something'

      namespace :pipeline do
        described_class.define(
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:unpause']

      expect(rake_task.creator.pipeline).to(eq(pipeline))
    end

    it 'uses a home directory of ENV["HOME"] by default' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'
      home_directory = '/some/path/to/home'

      ENV['HOME'] = home_directory

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:unpause']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided home directory when supplied' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'
      home_directory = 'build/fly'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config,
          home_directory: home_directory
        )
      end

      rake_task = Rake::Task['pipeline:unpause']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided unpause pipeline task name when present' do
      namespace :pipeline do
        described_class.define(
          unpause_task_name: :resume,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something',
          config: 'ci/pipeline.yml'
        )
      end

      expect(Rake.application)
        .to(have_task_defined('pipeline:resume'))
    end

    it 'uses the provided argument names when present' do
      argument_names = %i[argument names]

      namespace :pipeline do
        described_class.define(
          argument_names: argument_names,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something',
          config: 'ci/pipeline.yml'
        )
      end

      rake_task = Rake::Task['pipeline:unpause']

      expect(rake_task.arg_names).to(eq(argument_names))
    end

    it 'passes value for team when available' do
      target = 'supercorp-ci'
      team = 'supercorp-team'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :pipeline do
        described_class.define(
          target: target,
          team: team,
          pipeline: pipeline,
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:unpause']

      expect(rake_task.creator.team).to(eq(team))
    end

    it 'passes nil for team when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      config = 'ci/pipeline.yml'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          config: config
        )
      end

      rake_task = Rake::Task['pipeline:unpause']

      expect(rake_task.creator.team).to(be_nil)
    end
  end

  describe 'push task' do
    it 'configures with target' do
      target = 'supercorp-ci'

      namespace :pipeline do
        described_class.define(
          target: target
        )
      end

      rake_task = Rake::Task['pipeline:push']

      expect(rake_task.creator.target).to(eq(target))
    end

    it 'configures with pipeline' do
      pipeline = 'supercorp-something'

      namespace :pipeline do
        described_class.define(
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:push']

      expect(rake_task.creator.pipeline).to(eq(pipeline))
    end

    it 'uses the provided push pipeline task name when present' do
      namespace :pipeline do
        described_class.define(
          push_task_name: :publish,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something',
          config: 'ci/pipeline.yml'
        )
      end

      expect(Rake.application)
        .to(have_task_defined('pipeline:publish'))
    end

    it 'uses the provided get pipeline task name when present' do
      namespace :pipeline do
        described_class.define(
          get_task_name: :fetch,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something',
          config: 'ci/pipeline.yml'
        )
      end

      rake_task = Rake::Task['pipeline:push']

      expect(rake_task.creator.get_task_name).to(eq(:fetch))
    end

    it 'uses the set pipeline task name when present' do
      namespace :pipeline do
        described_class.define(
          set_task_name: :send,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something',
          config: 'ci/pipeline.yml'
        )
      end

      rake_task = Rake::Task['pipeline:push']

      expect(rake_task.creator.set_task_name).to(eq(:send))
    end

    it 'uses the provided unpause pipeline task names when present' do
      namespace :pipeline do
        described_class.define(
          unpause_task_name: :resume,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something',
          config: 'ci/pipeline.yml'
        )
      end

      rake_task = Rake::Task['pipeline:push']

      expect(rake_task.creator.unpause_task_name).to(eq(:resume))
    end

    it 'uses the provided argument names when present' do
      argument_names = %i[argument names]

      namespace :pipeline do
        described_class.define(
          argument_names: argument_names,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something',
          config: 'ci/pipeline.yml'
        )
      end

      rake_task = Rake::Task['pipeline:push']

      expect(rake_task.arg_names).to(eq(argument_names))
    end
  end

  describe 'destroy task' do
    it 'configures with target' do
      target = 'supercorp-ci'

      namespace :pipeline do
        described_class.define(
          target: target
        )
      end

      rake_task = Rake::Task['pipeline:destroy']

      expect(rake_task.creator.target).to(eq(target))
    end

    it 'configures with pipeline' do
      pipeline = 'supercorp-something'

      namespace :pipeline do
        described_class.define(
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:destroy']

      expect(rake_task.creator.pipeline).to(eq(pipeline))
    end

    it 'passes value for non interactive when available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      non_interactive = true

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          non_interactive: non_interactive
        )
      end

      rake_task = Rake::Task['pipeline:destroy']

      expect(rake_task.creator.non_interactive).to(eq(non_interactive))
    end

    it 'passes nil for non interactive when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:destroy']

      expect(rake_task.creator.non_interactive).to(be_nil)
    end

    it 'passes value for team when available' do
      target = 'supercorp-ci'
      team = 'supercorp-team'
      pipeline = 'supercorp-something'

      namespace :pipeline do
        described_class.define(
          target: target,
          team: team,
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:destroy']

      expect(rake_task.creator.team).to(eq(team))
    end

    it 'passes nil for team when not available' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:destroy']

      expect(rake_task.creator.team).to(be_nil)
    end

    it 'uses a home directory of ENV["HOME"] by default' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      home_directory = '/some/path/to/home'

      ENV['HOME'] = home_directory

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline
        )
      end

      rake_task = Rake::Task['pipeline:destroy']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided home directory when supplied' do
      target = 'supercorp-ci'
      pipeline = 'supercorp-something'
      home_directory = '/tmp/fly'

      namespace :pipeline do
        described_class.define(
          target: target,
          pipeline: pipeline,
          home_directory: home_directory
        )
      end

      rake_task = Rake::Task['pipeline:destroy']

      expect(rake_task.creator.home_directory).to(eq(home_directory))
    end

    it 'uses the provided destroy task name when present' do
      namespace :pipeline do
        described_class.define(
          target: 'supercorp-ci',
          pipeline: 'supercorp-something',

          destroy_task_name: :delete
        )
      end

      expect(Rake.application)
        .to(have_task_defined('pipeline:delete'))
    end

    it 'uses the provided argument names when present' do
      argument_names = %i[argument names]

      namespace :pipeline do
        described_class.define(
          argument_names: argument_names,

          target: 'supercorp-ci',
          pipeline: 'supercorp-something'
        )
      end

      rake_task = Rake::Task['pipeline:destroy']

      expect(rake_task.arg_names).to(eq(argument_names))
    end
  end
end
