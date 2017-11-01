require 'spec_helper'
require 'fileutils'

describe RakeFly::Tasks::SetPipeline do
  include_context :rake

  before(:each) do
    namespace :fly do
      task :ensure
    end
  end


  it 'adds a set_pipeline task in the namespace in which it is created' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['something:set_pipeline']).not_to be_nil
  end

  it 'gives the set_pipeline task a description' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(rake.last_description)
        .to(eq('Set pipeline supercorp-something for target supercorp-ci'))
  end

  it 'allows the task name to be overridden' do
    namespace :pipeline do
      subject.new(:set) do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['pipeline:set']).not_to be_nil
  end

  it 'allows multiple set_pipeline tasks to be declared' do
    namespace :something1 do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something1'
        t.config = 'ci/pipeline.yml'
      end
    end

    namespace :something2 do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    something1_set_pipeline = Rake::Task['something1:set_pipeline']
    something2_set_pipeline = Rake::Task['something2:set_pipeline']

    expect(something1_set_pipeline).not_to be_nil
    expect(something2_set_pipeline).not_to be_nil
  end

  it 'depends on the fly:ensure task by default' do
    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['something:set_pipeline'].prerequisite_tasks)
        .to(include(Rake::Task['fly:ensure']))
  end

  it 'depends on the provided task if specified' do
    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    namespace :something do
      subject.new do |t|
        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'

        t.ensure_task = 'tools:fly:ensure'
      end
    end

    expect(Rake::Task['something:set_pipeline'].prerequisite_tasks)
        .to(include(Rake::Task['tools:fly:ensure']))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = [:deployment_identifier, :region]

    namespace :tools do
      namespace :fly do
        task :ensure
      end
    end

    namespace :something do
      subject.new do |t|
        t.argument_names = argument_names

        t.target = 'supercorp-ci'
        t.pipeline = 'supercorp-something2'
        t.config = 'ci/pipeline.yml'
      end
    end

    expect(Rake::Task['something:set_pipeline'].arg_names)
        .to(eq(argument_names))
  end

  it 'sets the specific pipeline and config for the specified target' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(
                          target: target,
                          pipeline: pipeline,
                          config: config)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'uses the provided target factory when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.argument_names = [:target]

      t.target = lambda {|args| args.target}
      t.pipeline = pipeline
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(target: target)))

    Rake::Task['set_pipeline'].invoke(target)
  end

  it 'uses the provided pipeline factory when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.argument_names = [:pipeline]

      t.target = target
      t.pipeline = lambda {|args| args.pipeline}
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(
                          target: target,
                          pipeline: pipeline)))

    Rake::Task['set_pipeline'].invoke(pipeline)
  end

  it 'uses the provided config factory when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.argument_names = [:config]

      t.target = target
      t.pipeline = pipeline
      t.config = lambda {|args| args.config}
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(config: config)))

    Rake::Task['set_pipeline'].invoke(config)
  end

  it 'passes the provided vars when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    vars = {
        key1: 'value1',
        key2: 'value2'
    }

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.vars = vars
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(vars: vars)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'passes nil for vars when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(vars: nil)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'uses the provided vars factory when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    important_var = 'some-value'

    subject.new do |t|
      t.argument_names = [:important_var]

      t.target = target
      t.pipeline = pipeline
      t.config = config

      t.vars = lambda {|args| {the_var: args.important_var}}
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(
                          vars: {the_var: important_var})))

    Rake::Task['set_pipeline'].invoke(important_var)
  end

  it 'passes the provided var files when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    var_files = [
        'config/variables.yml',
        'config/secrets.yml'
    ]

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.var_files = var_files
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(var_files: var_files)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'passes nil for var files when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(var_files: nil)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'uses the provided var files factory when supplied' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'
    important_var_file = 'some/file.yml'

    subject.new do |t|
      t.argument_names = [:important_var_file]

      t.target = target
      t.pipeline = pipeline
      t.config = config

      t.var_files = lambda {|args| [args.important_var_file]}
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(
                          var_files: [important_var_file])))

    Rake::Task['set_pipeline'].invoke(important_var_file)
  end

  it 'passes the provided value for non-interactive when present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
      t.non_interactive = true
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(non_interactive: true)))

    Rake::Task['set_pipeline'].invoke
  end

  it 'passes nil for non-interactive when not present' do
    target = 'supercorp-ci'
    pipeline = 'supercorp-something'
    config = 'ci/pipeline.yml'

    subject.new do |t|
      t.target = target
      t.pipeline = pipeline
      t.config = config
    end

    stub_puts
    stub_ruby_fly

    expect(RubyFly)
        .to(receive(:set_pipeline)
                .with(hash_including(non_interactive: nil)))

    Rake::Task['set_pipeline'].invoke
  end

  def stub_puts
    allow_any_instance_of(Kernel).to(receive(:puts))
  end

  def stub_ruby_fly
    allow(RubyFly).to(receive(:set_pipeline))
  end
end
