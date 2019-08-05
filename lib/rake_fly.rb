require 'semantic'
require 'rake_dependencies'
require 'ruby_fly'
require 'rake_fly/version'
require 'rake_fly/tasklib'
require 'rake_fly/tasks'

BREAKING_VERSION = '5.0.0'

module RakeFly
  include RubyFly

  def self.define_installation_tasks(opts = {})
    namespace = opts[:namespace] || :fly
    version = opts[:version] || '2.7.0'
    path = opts[:path] || File.join('vendor', 'fly')

    RubyFly.configure do |c|
      c.binary = File.join(path, 'bin', 'fly')
    end

    RakeDependencies::Tasks::All.new do |t|
      t.namespace = namespace
      t.dependency = 'fly'
      t.version = version
      t.path = path
      t.type = self.type(version)

      t.os_ids = {mac: 'darwin', linux: 'linux'}

      t.uri_template = self.uri_template(version)
      t.file_name_template = self.file_name_template(version)

      t.needs_fetch = lambda do |parameters|
        fly_binary = File.join(
            parameters[:path], parameters[:binary_directory], 'fly')

        !(File.exist?(fly_binary) && RubyFly.version == version)
      end
    end
  end

  private

  def self.new_format?(version)
    Semantic::Version.new(version) >= 
      Semantic::Version.new(BREAKING_VERSION)
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
