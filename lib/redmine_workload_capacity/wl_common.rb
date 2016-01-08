module WlCommon
	def authenticate
    	render_403 if !User.current.wl_manage_right?(@project) && !User.current.allowed_to?(:view_global_allocation_check, @project) && Member.find_by(user_id: User.current.id, project_id: @project.id).nil?  
  	end

  	def set_project
		@project ||= Project.find(params[:project_id])
	end
end