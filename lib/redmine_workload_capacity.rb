Rails.configuration.to_prepare do
  require 'redmine_workload_capacity/patches/projects_helper_patch'
end