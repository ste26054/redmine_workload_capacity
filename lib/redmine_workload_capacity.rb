Rails.configuration.to_prepare do

  require 'redmine_workload_capacity/refinements/user_refinement'

  require 'redmine_workload_capacity/wl_scope_extensions'
  require 'redmine_workload_capacity/wl_common_validations'
  require 'redmine_workload_capacity/wl_logic'
  require 'redmine_workload_capacity/patches/projects_helper_patch'

  require 'redmine_workload_capacity/wl_project_window_logic'
  require 'redmine_workload_capacity/wl_users'

  require 'redmine_workload_capacity/patches/project_patch'
  require 'redmine_workload_capacity/patches/member_patch'
  require 'redmine_workload_capacity/patches/user_patch'

  require 'redmine_workload_capacity/wl_common'
end