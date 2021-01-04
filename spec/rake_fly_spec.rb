require 'spec_helper'

RSpec.describe RakeFly do
  it 'has a version number' do
    expect(RakeFly::VERSION).not_to be nil
  end

  it 'includes all the RubyFly methods' do
    expect(RakeFly)
        .to(respond_to(
            :get_pipeline, :set_pipeline, :unpause_pipeline, :version))
  end

  context 'define_installation_tasks' do
    context 'when configuring RubyFly' do
      it 'sets the binary using a path of vendor/fly by default' do
        RakeFly.define_installation_tasks

        expect(RubyFly.configuration.binary)
            .to(eq('vendor/fly/bin/fly'))
      end

      it 'uses the supplied path when provided' do
        RakeFly.define_installation_tasks(path: 'tools/fly')

        expect(RubyFly.configuration.binary)
            .to(eq('tools/fly/bin/fly'))
      end
    end

    context 'when instantiating RakeDependencies::Tasks::All' do
      it 'sets the namespace to fly by default' do
        task_set = RakeFly.define_installation_tasks

        expect(task_set.namespace).to(eq("fly"))
      end

      it 'uses the supplied namespace when provided' do
        task_set = RakeFly.define_installation_tasks(namespace: :tools_fly)

        expect(task_set.namespace).to(eq("tools_fly"))
      end

      it 'sets the dependency to fly' do
        task_set = RakeFly.define_installation_tasks

        expect(task_set.dependency).to(eq('fly'))
      end

      it 'sets the version to 2.7.0 by default' do
        task_set = RakeFly.define_installation_tasks

        expect(task_set.version).to(eq('2.7.0'))
      end

      it 'uses the supplied version when provided' do
        task_set = RakeFly.define_installation_tasks(version: '2.6.0')

        expect(task_set.version).to(eq('2.6.0'))
      end

      it 'uses a path of vendor/fly by default' do
        task_set = RakeFly.define_installation_tasks

        expect(task_set.path).to(eq('vendor/fly'))
      end

      it 'uses the supplied path when provided' do
        task_set = RakeFly.define_installation_tasks(
            path: File.join('tools', 'fly'))

        expect(task_set.path).to(eq('tools/fly'))
      end

      it 'uses os_ids of darwin and linux' do
        task_set = RakeFly.define_installation_tasks

        expect(task_set.os_ids)
            .to(eq({mac: 'darwin', linux: 'linux'}))
      end

      # TODO: test needs_fetch more thoroughly
      it 'provides a needs_fetch checker' do
        task_set = RakeFly.define_installation_tasks

        expect(task_set.needs_fetch).not_to(be(nil))
      end

      context 'when installing versions 5.0.0 and above' do
        it 'uses a type of tgz' do
          task_set = RakeFly.define_installation_tasks(version: '5.0.0')

          expect(task_set.type).to(eq(:tgz))
        end

        it 'uses the correct URI template' do
          task_set = RakeFly.define_installation_tasks(version: '5.0.0')

          expect(task_set.uri_template)
              .to(eq(
                  'https://github.com/concourse/concourse/releases/download' +
                      '/v<%= @version %>' +
                      '/fly-<%= @version %>-<%= @os_id %>-amd64<%= @ext %>'))
        end

        it 'uses the correct file name template' do
          task_set = RakeFly.define_installation_tasks(version: '5.0.0')

          expect(task_set.file_name_template)
              .to(eq('fly-<%= @version %>-<%= @os_id %>-amd64<%= @ext %>'))
        end
      end

      context 'when installing older versions' do
        it 'uses a type of uncompressed' do
          task_set = RakeFly.define_installation_tasks

          expect(task_set.type).to(eq(:uncompressed))
        end

        it 'uses the correct URI template' do
          task_set = RakeFly.define_installation_tasks

          expect(task_set.uri_template)
              .to(eq('https://github.com/concourse/concourse/releases/' +
                  'download/v<%= @version %>/' +
                  'fly_<%= @os_id %>_amd64'))
        end

        it 'uses the correct file name template' do
          task_set = RakeFly.define_installation_tasks

          expect(task_set.file_name_template)
              .to(eq('fly_<%= @os_id %>_amd64'))
        end

        it 'uses the correct source binary name template' do
          task_set = RakeFly.define_installation_tasks

          expect(task_set.source_binary_name_template)
              .to(eq('fly_<%= @os_id %>_amd64'))
        end

        it 'uses the correct target binary name template' do
          task_set = RakeFly.define_installation_tasks

          expect(task_set.target_binary_name_template)
              .to(eq('fly'))
        end
      end
    end
  end
end
