# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :projects do
	resource :wl_project_windows
end

resources :users do
	resources :wl_project_windows do
		resources :wl_project_allocations, :wl_custom_allocations, :wl_user_overtimes
	end
end