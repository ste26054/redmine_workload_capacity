# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :projects do
	resource :wl_project_window

	resources :users do
		resource :wl_project_allocation
 		resources :wl_custom_allocations
 		resources :wl_user_overtimes
 	end

end

get '/projects/:project_id/workload/board', :to => 'wl_boards#index'
