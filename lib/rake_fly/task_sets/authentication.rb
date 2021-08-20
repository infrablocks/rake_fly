require 'rake_factory'

require_relative '../tasks/authentication/login'
require_relative '../tasks/authentication/ensure'

module RakeFly
  module TaskSets
    class Authentication < RakeFactory::TaskSet
      prepend RakeFactory::Namespaceable

      parameter :argument_names, default: []

      parameter :target, required: true
      parameter :concourse_url, required: true
      parameter :team, default: 'main'

      parameter :backend, default: RakeFly::Tasks::Authentication::Login::ApiBackend
      parameter :username
      parameter :password

      parameter :home_directory,
          default: RakeFactory::DynamicValue.new { |_| ENV['HOME'] }

      parameter :login_task_name, default: :login
      parameter :ensure_task_name, default: :ensure

      parameter :fly_ensure_task_name, default: :'fly:ensure'

      task Tasks::Authentication::Login,
          name: RakeFactory::DynamicValue.new { |ts|
            ts.login_task_name
          }
      task Tasks::Authentication::Ensure,
          name: RakeFactory::DynamicValue.new { |ts|
            ts.ensure_task_name
          }
    end
  end
end
