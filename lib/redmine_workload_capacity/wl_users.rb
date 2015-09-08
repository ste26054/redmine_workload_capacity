module WlUser
	using RedmineWorkloadCapacity::Refinements::UserRefinement
	
	def self.wl_users_for_project(project)
		 project.users.to_a.delete_if {|u| !u.allowed_to?(:appear_in_project_allocation, project)}.uniq
	end

	def self.wl_members_for_project(project)
		project.members.to_a.delete_if {|m| !m.user.allowed_to?(:appear_in_project_allocation, project)}.uniq
	end

	def self.wl_member?(member)
		return member.user.allowed_to?(:appear_in_project_allocation, member.project)
	end

	def self.wl_manage_right?(user, project)
		return user.allowed_to?(:manage_project_allocation, project)
	end

	def self.leave_request_list(user, wl_project_window)
    	leave_request_ids = LeaveRequest.for_user(user.id).overlaps(wl_project_window.start_date, wl_project_window.end_date).pluck(:id)
    	leave_request_ids.delete_if {|l| LeaveRequest.find(l).get_status.in?(["created", "rejected"])}
    	return LeaveRequest.where(id: leave_request_ids).order(:from_date)
  end
end