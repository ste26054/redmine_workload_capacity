module WlUser
	using RedmineWorkloadCapacity::Refinements::UserRefinement
	
	def self.wl_users_for_project(project)
		 project.members.map(&:user).delete_if {|u| !u.allowed_to?(:appear_in_project_workload, project)}
	end
end