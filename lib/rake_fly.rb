# frozen_string_literal: true

require 'semantic'
require 'rake_dependencies'
require 'ruby_fly'
require 'rake_fly/version'
require 'rake_fly/tasks'
require 'rake_fly/task_sets'

module RakeFly
  include RubyFly

  ARTIFACT_FORMAT_CHANGE_VERSION = '5.0.0'

  def self.define_installation_tasks(opts = {})
    option_resolver = OptionResolver.new(opts)

    RubyFly.configure do |c|
      c.binary = option_resolver.fly_binary_path
    end

    RakeDependencies::TaskSets::All.define(
      option_resolver.installation_task_set_options
    )
  end

  def self.define_authentication_tasks(opts = {}, &)
    RakeFly::TaskSets::Authentication.define(opts, &)
  end

  def self.define_pipeline_tasks(opts = {}, &)
    RakeFly::TaskSets::Pipeline.define(opts, &)
  end

  def self.define_project_tasks(opts = {}, &)
    RakeFly::TaskSets::Project.define(opts, &)
  end

  class OptionResolver
    attr_reader :opts

    def initialize(opts)
      @opts = opts
    end

    # rubocop:disable Metrics/MethodLength
    def installation_task_set_options
      task_set_opts = {
        namespace:,
        dependency:,
        version:,
        path:,
        type:,
        platform_os_names:,
        uri_template:,
        file_name_template:,
        needs_fetch: needs_fetch_check_lambda
      }

      unless new_format?
        task_set_opts[:source_binary_name_template] =
          source_binary_name_template
        task_set_opts[:target_binary_name_template] =
          target_binary_name_template
      end

      task_set_opts
    end
    # rubocop:enable Metrics/MethodLength

    def fly_binary_path
      File.join(path, 'bin', 'fly')
    end

    def namespace
      opts[:namespace] || :fly
    end

    def dependency
      'fly'
    end

    def version
      opts[:version] || '2.7.0'
    end

    def path
      opts[:path] || File.join('vendor', 'fly')
    end

    def type
      if new_format?
        :tgz
      else
        :uncompressed
      end
    end

    def platform_os_names
      { darwin: 'darwin', linux: 'linux' }
    end

    def uri_template
      if new_format?
        'https://github.com/concourse/concourse/releases/download' \
          '/v<%= @version %>' \
          '/fly-<%= @version %>-<%= @platform_os_name %>-amd64<%= @ext %>'
      else
        'https://github.com/concourse/concourse/releases/' \
          'download/v<%= @version %>/fly_<%= @platform_os_name %>_amd64'
      end
    end

    def file_name_template
      if new_format?
        'fly-<%= @version %>-<%= @platform_os_name %>-amd64<%= @ext %>'
      else
        'fly_<%= @platform_os_name %>_amd64'
      end
    end

    def target_binary_name_template
      'fly'
    end

    def source_binary_name_template
      'fly_<%= @platform_os_name %>_amd64'
    end

    def needs_fetch_check_lambda
      lambda { |t|
        fly_binary = File.join(t.path, t.binary_directory, 'fly')

        !(File.exist?(fly_binary) && RubyFly.version == version)
      }
    end

    def new_format?
      Semantic::Version.new(version) >=
        Semantic::Version.new(ARTIFACT_FORMAT_CHANGE_VERSION)
    end
  end
end
