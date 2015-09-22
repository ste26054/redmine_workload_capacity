module WlUser
	using RedmineWorkloadCapacity::Refinements::UserRefinement
	include WlProjectWindowLogic

    def self.users_for_project_role(project, role)
		users = []
		members = project.members.to_a
		members.each do |member|
			role_ids = member.roles.map{ |role| role.id }
			if role.id.in?(role_ids)
				users << member.user
			end
		end	
		return users.uniq
	end	

	def self.wl_users_for_project(project)
		 wl_users = []
		 display_role_ids_list = WlProjectWindowLogic.retrieve_display_role_ids_list(project)
		 unless display_role_ids_list.empty?
		 	display_role_ids_list.each do |role_id|
		 		role = Role.find(role_id)
		 		wl_users << self.users_for_project_role(project, role)
		 		wl_users.flatten(1)
		 	end
		 	return wl_users.flatten.uniq
		 end
	end

	def self.wl_members_for_project(project)
		wl_members = []
		wl_users = wl_users_for_project(project)
		
		unless wl_users.empty?
			wl_users.each do |wl_user|
				wl_members << Member.where(user_id: wl_user.id, project_id: project.id)
				wl_members.flatten(1)
			end
			return wl_members.flatten
		end
	end

	def self.wl_member?(member)
		wl_members = wl_members_for_project(member.project)
		valid_member = false
		unless wl_members.empty?
			if member.in?wl_members
				valid_member = true
			end
		end
		return valid_member
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