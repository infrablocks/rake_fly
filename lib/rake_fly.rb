require 'rake_dependencies'
require 'ruby_fly'
require 'rake_fly/version'
require 'rake_fly/tasklib'
require 'rake_fly/tasks'

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
      t.type = :zip

      t.os_ids = {mac: 'darwin', linux: 'linux'}

      t.uri_template = "https://github.com/concourse/concourse/releases/" +
          "download/v<%= @version %>/fly_<%= @os_id %>_amd64"
      t.file_name_template = "fly_<%= @os_id %>_amd64"

      t.source_binary_name_template = "fly_<%= @os_id %>_amd64"
      t.target_binary_name_template = 'fly'

      t.needs_fetch = lambda do |parameters|
        fly_binary = File.join(
            parameters[:path], parameters[:binary_directory], 'fly')

        !(File.exist?(fly_binary) && RubyFly.version == version)
      end
    end
  end
end
