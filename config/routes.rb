# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :projects do
	resource :wl_project_window

	resources :users do
		resource :wl_project_allocation
 		resources :wl_custom_allocations
 		resources :wl_user_overtimes

 		resources :wl_custom_project_windows, :except => [:show]
 	end

end

get '/projects/:project_id/workload/board', :to => 'wl_boards#index'

get '/projects/:project_id/workload/check', :to => 'wl_check_loggedtime#show'

get '/projects/:project_id/update_wlconfigure/:member_id', :to => 'wl_boards#update_wlconfigure_member_contentline', as: :test
