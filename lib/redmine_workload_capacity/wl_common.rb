module WlCommon
	def authenticate
    	render_403 unless User.current.wl_manage_right?(@project)
  	end
end