module WlProjectWindowLogic

  def self.retrieve_display_role_ids_list(project)
  	role_list = []
  	wl_pw = WlProjectWindow.find_by(project_id: project.id)
  	unless wl_pw.nil?
   		role_list = wl_pw.display_role_ids
	end
 	return role_list
  end

   def self.retrieve_tooltip_role_ids_list(project)
   	role_list = []
   	wl_pw = WlProjectWindow.find_by(project_id: project.id)
  	unless wl_pw.nil?
   		role_list = wl_pw.tooltip_role_ids
  	end
  	return role_list
  end

end