module WlProjectWindowLogic

  def self.retrieve_display_role_ids_list(project)
   return WlProjectWindow.find_by(project_id: project.id).display_role_ids
  end

   def self.retrieve_tooltip_role_ids_list(project)
   return WlProjectWindow.find_by(project_id: project.id).tooltip_role_ids
  end

end