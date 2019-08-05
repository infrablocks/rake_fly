require 'spec_helper'

RSpec.describe RakeFly do
  it 'has a version number' do
    expect(RakeFly::VERSION).not_to be nil
  end

  it 'includes all the RubyTerraform methods' do
    expect(RakeFly)
        .to(respond_to(
                :get_pipeline, :set_pipeline, :unpause_pipeline, :version))
  end

  context 'define_installation_tasks' do
    context 'when configuring RubyFly' do
      it 'sets the binary using a path of vendor/fly by default' do
        config = stubbed_ruby_fly_config

        allow(RakeDependencies::Tasks::All).to(receive(:new))
        expect(RubyFly).to(receive(:configure).and_yield(config))

        expect(config)
            .to(receive(:binary=)
                    .with('vendor/fly/bin/fly'))

        RakeFly.define_installation_tasks
      end

      it 'uses the supplied path when provided' do
        config = stubbed_ruby_fly_config

        allow(RakeDependencies::Tasks::All).to(receive(:new))
        expect(RubyFly).to(receive(:configure).and_yield(config))

        expect(config)
            .to(receive(:binary=)
                    .with('tools/fly/bin/fly'))

        RakeFly.define_installation_tasks(
            path: 'tools/fly')
      end
    end

    context 'when instantiating RakeDependencies::Tasks::All' do
      it 'sets the namespace to fly by default' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyFly).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:namespace=).with(:fly))

        RakeFly.define_installation_tasks
      end

      it 'uses the supplied namespace when provided' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyFly).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:namespace=).with(:tools_fly))

        RakeFly.define_installation_tasks(
            namespace: :tools_fly)
      end

      it 'sets the dependency to fly' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyFly).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:dependency=).with('fly'))

        RakeFly.define_installation_tasks
      end

      it 'sets the version to 2.7.0 by default' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyFly).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:version=).with('2.7.0'))

        RakeFly.define_installation_tasks
      end

      it 'uses the supplied version when provided' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyFly).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:version=).with('2.6.0'))

        RakeFly.define_installation_tasks(
            version: '2.6.0')
      end

      it 'uses a path of vendor/fly by default' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyFly).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:path=).with('vendor/fly'))

        RakeFly.define_installation_tasks
      end

      it 'uses the supplied path when provided' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyFly).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:path=).with('tools/fly'))

        RakeFly.define_installation_tasks(
            path: File.join('tools', 'fly'))
      end

      it 'uses os_ids of darwin and linux' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyFly).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task)
            .to(receive(:os_ids=)
                    .with({mac: 'darwin', linux: 'linux'}))

        RakeFly.define_installation_tasks
      end

      # TODO: test needs_fetch more thoroughly
      it 'provides a needs_fetch checker' do
        task = stubbed_rake_dependencies_all_task

        allow(RubyFly).to(receive(:configure))
        expect(RakeDependencies::Tasks::All)
            .to(receive(:new).and_yield(task))

        expect(task).to(receive(:needs_fetch=))

        RakeFly.define_installation_tasks
      end

      context 'when installing versions 5.0.0 and above' do
        it 'uses a type of tgz' do
          task = stubbed_rake_dependencies_all_task
  
          allow(RubyFly).to(receive(:configure))
          expect(RakeDependencies::Tasks::All)
              .to(receive(:new).and_yield(task))
  
          expect(task).to(receive(:type=).with(:tgz))
  
          RakeFly.define_installation_tasks(version: '5.0.0')
        end

        it 'uses the correct URI template' do
          task = stubbed_rake_dependencies_all_task
  
          allow(RubyFly).to(receive(:configure))
          expect(RakeDependencies::Tasks::All)
              .to(receive(:new).and_yield(task))
  
          expect(task)
              .to(receive(:uri_template=)
                      .with('https://github.com/concourse/concourse/releases/download' +
                                '/v<%= @version %>' + 
                                '/fly-<%= @version %>-<%= @os_id %>-amd64<%= @ext %>'))
  
          RakeFly.define_installation_tasks(version: '5.0.0')
        end
  
        it 'uses the correct file name template' do
          task = stubbed_rake_dependencies_all_task
  
          allow(RubyFly).to(receive(:configure))
          expect(RakeDependencies::Tasks::All)
              .to(receive(:new).and_yield(task))
  
          expect(task)
              .to(receive(:file_name_template=)
                      .with('fly-<%= @version %>-<%= @os_id %>-amd64<%= @ext %>'))
  
          RakeFly.define_installation_tasks(version: '5.0.0')
        end
      end

      context 'when installing older versions' do
        it 'uses a type of uncompressed' do
          task = stubbed_rake_dependencies_all_task
        
          allow(RubyFly).to(receive(:configure))
          expect(RakeDependencies::Tasks::All)
              .to(receive(:new).and_yield(task))

          expect(task).to(receive(:type=).with(:uncompressed))

          RakeFly.define_installation_tasks
        end

        it 'uses the correct URI template' do
          task = stubbed_rake_dependencies_all_task

          allow(RubyFly).to(receive(:configure))
          expect(RakeDependencies::Tasks::All)
              .to(receive(:new).and_yield(task))

          expect(task)
              .to(receive(:uri_template=)
                      .with('https://github.com/concourse/concourse/releases/' +
                                'download/v<%= @version %>/' +
                                'fly_<%= @os_id %>_amd64'))

          RakeFly.define_installation_tasks
        end

        it 'uses the correct file name template' do
          task = stubbed_rake_dependencies_all_task

          allow(RubyFly).to(receive(:configure))
          expect(RakeDependencies::Tasks::All)
              .to(receive(:new).and_yield(task))

          expect(task)
              .to(receive(:file_name_template=)
                      .with('fly_<%= @os_id %>_amd64'))

          RakeFly.define_installation_tasks
        end
      end
    end
  end

  def double_allowing(*messages)
    instance = double
    messages.each do |message|
      allow(instance).to(receive(message))
    end
    instance
  end

  def stubbed_ruby_fly_config
    double_allowing(:binary=)
  end

  def stubbed_rake_dependencies_all_task
    double_allowing(
        :namespace=, :dependency=, :version=, :path=, :type=, :os_ids=,
        :uri_template=, :file_name_template=,
        :source_binary_name_template=, :target_binary_name_template=,
        :needs_fetch=)
  end

  def stubbed_rake_terraform_all_task
    double_allowing(
        :configuration_name=, :configuration_directory=,
        :backend=, :backend_config=, :vars=, :state_file=,
        :no_color=, :no_backup=, :backup=,
        :ensure_task=, :provision_task_name=, :destroy_task_name=)
  end
end
