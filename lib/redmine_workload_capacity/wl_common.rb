module WlCommon
	def authenticate
    	render_403 unless User.current.wl_manage_right?(@project) || User.current.allowed_to?(:view_global_allocation_check, @project) || User.current.members.where(project_id:  @project.id).first.wl_member?
  	end
end