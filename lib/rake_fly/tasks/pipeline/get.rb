require 'ruby_fly'
require 'rake_factory'

module RakeFly
  module Tasks
    module Pipeline
      class Get < RakeFactory::Task
        default_name :get
        default_prerequisites RakeFactory::DynamicValue.new { |t|
          [t.fly_ensure_task_name]
        }
        default_description RakeFactory::DynamicValue.new { |t|
          pipeline = t.pipeline || '<derived>'
          target = t.target || '<derived>'
  
          "Get pipeline #{pipeline} for target #{target}"
        }
  
        parameter :target, :required => true
        parameter :pipeline, :required => true

        parameter :home_directory,
            default: RakeFactory::DynamicValue.new { |_| ENV['HOME'] }

        parameter :fly_ensure_task_name, :default => :'fly:ensure'
  
        action do |t|
          puts "Getting pipeline #{t.pipeline} for target #{t.target}..."
          RubyFly.get_pipeline(
              target: t.target,
              pipeline: t.pipeline,
              environment: {
                  "HOME" => t.home_directory
              })
        end
      end
    end
  end
end