# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :projects do
	resource :wl_project_window
	
	resources :gr_graphs do 
		resources :gr_series, :except => [:show]
		resource :gr_category

		collection do
			match '/:gr_graph_id/set_params', :to => 'gr_graphs#set_params', as: :set, :via => [:get, :post]
			get '/:gr_graph_id/display', :to => 'gr_graphs#display_graph', as: :display_graph_content
			get '/perso_index', :to => 'gr_graphs#personalise_index', as: :personalise_index
			post '/order_blocks', :to => 'gr_graphs#order_blocks', as: :order_blocks
			post '/add_block', :to => 'gr_graphs#add_block', as: :add_block
			post '/remove_block', :to => 'gr_graphs#remove_block', as: :remove_block
		end
	end

	resources :users do
		resource :wl_project_allocation
 		resources :wl_custom_allocations
 		resources :wl_user_overtimes

 		resources :wl_custom_project_windows, :except => [:show]	
 	end

end

get '/projects/:project_id/workload/board', :to => 'wl_boards#index'

	get '/projects/:project_id/workload/update_wlconfigure/:member_id', :to => 'wl_boards#update_wlconfigure_member_contentline', as: :update_wlconfigure_member_contentline

get '/projects/:project_id/workload/check', :to => 'wl_check_loggedtime#show'

get '/projects/:project_id/workload/graph', :to => 'gr_graphs#index'
