Rails.application.routes.draw do
  devise_for :managers, controllers: {sessions: 'managers/sessions', 
                                      registrations: 'managers/registrations', 
                                      passwords: 'managers/passwords'}, 
                        path_names: { sign_in: 'login', 
                                      sign_out: 'logout' }

  root 'managers/mains#index'

  namespace :managers do
    root 'mains#index'


    concern :destroy_all do
      delete 'destroy_all', on: :collection
    end  

    resources :mains do    
      get 'navigation'
    end
    
    resources :checkpoints, :except => [:edit, :destroy] do      
      collection do
        # delete '/:uid', action: :destroy, as: 'destroy'
        # get '/:uid/edit',action: :edit, as: 'edit'
        # post '/:id/move_node', action: :move_node, as: 'move_node'
        # post 'import_ckp_file'
        post 'combine_node_catalogs_subject_checkpoints'
        post 'list'
      end
    end

    resources :subject_checkpoints, concerns: :destroy_all do    
      collection do   
        post '/:id/move_node', action: :move_node, as: 'move_node'
        get 'list'
        get 'get_subject_volume_ckps'
        get 'get_volume_catalog_ckps'
        post 'import_ckp_file'
      end
    end

    resources :roles, concerns: :destroy_all do
      resources :role_permissions, concerns: :destroy_all 
    end

    resources :node_structures, concerns: :destroy_all do 
      get "catalog_tree", on: :collection
      resources :node_catalogs, concerns: :destroy_all do 
        resources :checkpoints, concerns: :destroy_all do
          collection do
            get "tree"
          end
        end
      end
      resources :checkpoints, concerns: :destroy_all do
        collection do
          get "tree"
        end
      end
    end
    
    resources :permissions, concerns: :destroy_all
 
    resources :tenants, concerns: :destroy_all do
      collection do
        #delete 'destroy_all', :to => "tenants#destroy_all"
      end
    end

    resources :areas, concerns: :destroy_all do
      collection do
        get 'get_province'
        get 'get_city'
        get 'get_district'
        get 'get_tenants'
        get 'area_list'
      end
    end

    resources :papers, concerns: :destroy_all do
      collection do
        get 'new_import'
        post "import"
        post "export_ckpz_qzs"
      end
      member do
        post 'rollback'
        get 'download'
        get 'download_page'
        get 'new_paper_test'
        post 'create_paper_test'
        get 'export_file'
        get "combine"
        post "combine_obj"
      end
    end

    resources :checkpoint_systems, concerns: :destroy_all do
      member do
        post 'delete_checked'
      end

      resources :subject_ckps do
      end
    end

    resources :bank_tests, concerns: :destroy_all do
      member do
        get "combine"
        post "combine_obj"
        get "download_page"
        get "download"
        get "get_binded_stat"        
      end
    end

    resources :analyzers, concerns: :destroy_all
    resources :teachers, concerns: :destroy_all
    resources :pupils, concerns: :destroy_all
    resources :tenant_administrators, concerns: :destroy_all
    resources :project_administrators, concerns: :destroy_all
    resources :area_administrators, concerns: :destroy_all
    resources :node_catalogs, concerns: :destroy_all
    resources :dashbord do
      collection do
        get 'paper'
        get 'user'
        get 'quiz'
        get 'checkpoint'
        post 'checkpoint_list'
        get 'get_dashbord'
        post 'update_dashbord'
        post 'report_overall_stat'
        get 'report'
        get 'report_list'
        post 'report_single_stat'
      end
    end
  end

  mount RuCaptcha::Engine => "/rucaptcha"

  resources :checkpoints do 
    collection do 
      post 'get_nodes'
      get 'get_node_count'
#      get 'get_child_nodes'
#      get 'get_all_nodes'
#      post 'save_node'
#      post 'update_node'
#      post 'delete_node'
      get 'dimesion_tree'
      get 'get_ckp_data'
      get 'get_tree_data_by_subject'
      get 'get_tree_date_include_checkpoint_system'
    end
  end

  resources :subject_checkpoints do 
    collection do 
      get 'ztree_data_list'
    end
  end 

  resource :monitors do
    member do
      get 'get_task_status'
    end
  end
  
  resources :node_structures do
    collection do 
      get 'get_subjects'
      get 'get_grades'
      get 'get_versions'
      get 'get_units'
      get 'list'
      get 'catalog_list'
    end
  end

  get '/ckeditors/urlimage'=> "ckeditor#urlimage"

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get '*path', to: 'managers/mains#index'
end
