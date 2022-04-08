# frozen_string_literal: true

require 'rake_factory'

require_relative '../tasks/pipeline/get'
require_relative '../tasks/pipeline/set'
require_relative '../tasks/pipeline/unpause'
require_relative '../tasks/pipeline/push'

module RakeFly
  module TaskSets
    class Pipeline < RakeFactory::TaskSet
      prepend RakeFactory::Namespaceable

      parameter :argument_names, default: []

      parameter :target, required: true
      parameter :team
      parameter :pipeline, required: true
      parameter :config, required: true

      parameter :vars
      parameter :var_files
      parameter :non_interactive

      parameter :home_directory,
                default: RakeFactory::DynamicValue.new { |_| ENV['HOME'] }

      parameter :get_task_name, default: :get
      parameter :set_task_name, default: :set
      parameter :unpause_task_name, default: :unpause
      parameter :push_task_name, default: :push
      parameter :destroy_task_name, default: :destroy

      parameter :fly_ensure_task_name, default: :'fly:ensure'

      task Tasks::Pipeline::Get,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.get_task_name
           }
      task Tasks::Pipeline::Set,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.set_task_name
           }
      task Tasks::Pipeline::Unpause,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.unpause_task_name
           }
      task Tasks::Pipeline::Push,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.push_task_name
           }
      task Tasks::Pipeline::Destroy,
           name: RakeFactory::DynamicValue.new { |ts|
             ts.destroy_task_name
           }
    end
  end
end
