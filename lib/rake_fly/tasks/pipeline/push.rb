# frozen_string_literal: true

require 'ruby_fly'
require 'rake_factory'

module RakeFly
  module Tasks
    module Pipeline
      class Push < RakeFactory::Task
        default_name :push
        default_description(RakeFactory::DynamicValue.new do |t|
          pipeline = t.pipeline || '<derived>'
          target = t.target || '<derived>'

          "Push pipeline #{pipeline} to target #{target}"
        end)

        parameter :target, required: true
        parameter :pipeline, required: true

        parameter :get_task_name, default: :get
        parameter :set_task_name, default: :set
        parameter :unpause_task_name, default: :unpause

        action do |t, args|
          [
            t.application[t.set_task_name, t.scope],
            t.application[t.get_task_name, t.scope],
            t.application[t.unpause_task_name, t.scope]
          ].each do |task|
            task.invoke(*args)
          end
        end
      end
    end
  end
end
