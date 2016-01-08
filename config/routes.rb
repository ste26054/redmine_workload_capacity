# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :projects do
	resource :wl_project_window
	resources :gr_series
	resources :gr_categories

	resources :users do
		resource :wl_project_allocation
 		resources :wl_custom_allocations
 		resources :wl_user_overtimes

 		resources :wl_custom_project_windows, :except => [:show]
 		
 	end

end

get '/projects/:project_id/workload/board', :to => 'wl_boards#index'

get '/projects/:project_id/workload/check', :to => 'wl_check_loggedtime#show'

get '/projects/:project_id/update_wlconfigure/:member_id', :to => 'wl_boards#update_wlconfigure_member_contentline', as: :update_wlconfigure_member_contentline

get '/projects/:project_id/workload/graph', :to => 'gr_graphs#index'
match '/projects/:project_id/workload/graph/create', :to => 'gr_graphs#new_graph', as: :create_graph, :via => [:get, :post]
match '/projects/:project_id/workload/graph/add_element', :to => 'gr_graphs#add_element', as: :add_graph_element, :via => [:get, :post]


match '/projects/:project_id/workload/graph/create_series', :to => 'gr_graphs#create_series', as: :create_series, :via => [:get, :post]
