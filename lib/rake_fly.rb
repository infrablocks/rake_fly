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
    namespace = opts[:namespace] || :fly
    version = opts[:version] || '2.7.0'
    path = opts[:path] || File.join('vendor', 'fly')

    type = self.type(version)
    uri_template = self.uri_template(version)
    file_name_template = self.file_name_template(version)
    new_format = self.new_format?(version)

    task_set_opts = {
        namespace: namespace,
        dependency: 'fly',
        version: version,
        path: path,
        type: type,
        os_ids: {mac: 'darwin', linux: 'linux'},
        uri_template: uri_template,
        file_name_template: file_name_template,
        needs_fetch: lambda { |t|
          fly_binary = File.join(t.path, t.binary_directory, 'fly')

          !(File.exist?(fly_binary) && RubyFly.version == version)
        }}

    unless new_format
      task_set_opts[:source_binary_name_template] = "fly_<%= @os_id %>_amd64"
      task_set_opts[:target_binary_name_template] = "fly"
    end

    RubyFly.configure do |c|
      c.binary = File.join(path, 'bin', 'fly')
    end

    RakeDependencies::TaskSets::All.define(task_set_opts)
  end

  def self.define_authentication_tasks(opts = {}, &block)
    RakeFly::TaskSets::Authentication.define(opts, &block)
  end

  def self.define_pipeline_tasks(opts = {}, &block)
    RakeFly::TaskSets::Pipeline.define(opts, &block)
  end

  def self.define_project_tasks(opts = {}, &block)
    RakeFly::TaskSets::Project.define(opts, &block)
  end

  private

  def self.new_format?(version)
    Semantic::Version.new(version) >=
        Semantic::Version.new(ARTIFACT_FORMAT_CHANGE_VERSION)
  end

  def self.type(version)
    if self.new_format?(version)
      :tgz
    else
      :uncompressed
    end
  end

  def self.uri_template(version)
    if new_format?(version)
      "https://github.com/concourse/concourse/releases/download" +
          "/v<%= @version %>" +
          "/fly-<%= @version %>-<%= @os_id %>-amd64<%= @ext %>"
    else
      "https://github.com/concourse/concourse/releases/" +
          "download/v<%= @version %>/fly_<%= @os_id %>_amd64"
    end
  end

  def self.file_name_template(version)
    if new_format?(version)
      "fly-<%= @version %>-<%= @os_id %>-amd64<%= @ext %>"
    else
      "fly_<%= @os_id %>_amd64"
    end
  end
end
