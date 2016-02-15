module WlUser
	using RedmineWorkloadCapacity::Refinements::UserRefinement
	include WlProjectWindowLogic

    def self.users_for_project_role(project, role)
    	member_role_ids = MemberRole.where(role_id: role.id).pluck(:id)
		members_list = Member.includes(:member_roles, :project, :user).where(users: {status: 1}, project_id: project.id, member_roles: {id: member_role_ids}).to_a.uniq
		return members_list.map{|member| member.user}
	end	

	def self.all_for_project(project)
		 
		wl_members_list = WlMember.all_for_project(project)

		return wl_members_list.map{|member| member.user}
	end

	def self.wl_member?(member)
		wl_members = WlMember.all_for_project(member.project)
		valid_member = false
		unless wl_members.empty?
			if member.in?wl_members
				valid_member = true
			end
		end
		return valid_member
	end

	def self.wl_manage_right?(user, project)
		return user.admin? || user.allowed_to?(:manage_project_allocation, project)
	end

	def self.wl_view_global_right?(user, project)
		return user.allowed_to?(:view_global_allocation, project)
	end

	def self.leave_request_list(user, wl_project_window)
    	leave_request_ids = LeaveRequest.for_user(user.id).overlaps(wl_project_window.start_date, wl_project_window.end_date).pluck(:id)
    	leave_request_ids.delete_if {|l| LeaveRequest.find(l).get_status.in?(["created", "rejected"])}
    	return LeaveRequest.where(id: leave_request_ids).order(:from_date)
    end


  
end