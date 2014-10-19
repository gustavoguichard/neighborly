require 'sidekiq/web'

Neighborly::Application.routes.draw do

  post :hooks, to: 'webhook/events#create'

  devise_for :users, path: '',
    path_names:  {
      sign_in:  :login,
      sign_out: :logout,
      sign_up:  :sign_up
    },
    controllers: {
      confirmations:      :confirmations,
      omniauth_callbacks: :omniauth_callbacks,
      registrations:      :registrations,
      sessions:           :sessions
    }


  devise_scope :user do
    patch '/confirm', to: 'confirmations#confirm'
    post  '/sign_up', to: 'registrations#create', as: :sign_up
  end

  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }

  # Mountable engines
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount Neighborly::Api::Engine => '/api/', as: :neighborly_api
  mount Neighborly::Dashboard::Engine => '/dashboard/', as: :neighborly_dashboard
  mount Neighborly::Balanced::Bankaccount::Engine => '/balanced/bankaccount/', as: :neighborly_balanced_bankaccount
  mount Neighborly::Balanced::Engine => '/balanced/', as: :neighborly_balanced

  # Non production routes
  if Rails.env.development?
    resources :emails, only: [ :index, :show ]
  end

  root to: 'projects#index'

  # Static Pages
  get '/sitemap',               to: 'static#sitemap',             as: :sitemap
  get "/faq",                   to: "static#faq",                 as: :faq
  get "/terms",                 to: "static#terms",               as: :terms
  get "/privacy",               to: "static#privacy",             as: :privacy
  get "/start",                 to: "projects#start",             as: :start
  get '/about',                 to: 'static#about',               as: :about

  # Only accessible on development
  if Rails.env.development?
    get "/base",                to: "static#base",              as: :base
  end

  get "/discover/(:state)(/near/:near)(/category/:category)(/tags/:tags)(/search/:search)", to: "discover#index", as: :discover

  resources :tags, only: [:index]

  namespace :reports do
    resources :contribution_reports_for_project_owners, only: [:index]
  end

  # Temporary
  get '/projects/neuse-river-greenway-benches-draft', to: redirect('/projects/neuse-river-greenway-benches')

  resources :projects, except: [ :destroy ] do
    resources :faqs, controller: 'projects/faqs', only: [ :index, :create, :destroy ]
    resources :terms, controller: 'projects/terms', only: [ :index, :create, :destroy ]
    resources :activities, except: [:index, :show]
    resources :maturities, only: [:index], controller: :rewards

    collection do
      get 'video'
    end

    member do
      get 'reports'
      get 'statement'
      get 'budget'
      get 'success'
    end

    resources :rewards, except: :show do
      member do
        post 'sort'
      end
    end

    resources :contributions, controller: 'projects/contributions', except: :update
  end

  resource :brokerage_account, only: %i(new create edit update)

  scope :login, controller: :sessions do
    devise_scope :user do
      get   :set_new_user_email
      patch :confirm_new_user_email
    end
  end

  resources :users, path: 'neighbors' do
    post :validate_access_code
    get '/my-spot' => "users#my_spot", as: :my_spot

    resources :questions, controller: 'users/questions', only: [:new, :create]
    resources :projects, controller: 'users/projects', only: [ :index ]
    resources :contributions, controller: 'users/contributions', only: [:index]

    resources :authorizations, controller: 'users/authorizations', only: [:destroy]
    member do
      get :settings
      get :payments
      get :edit
      put :update_email
      put :update_password
    end
  end

  get :contact, to: 'contacts#new'
  resources :contacts, only: [:create]

  resources :images, only: [:new, :create]

  namespace :markdown do
    resources :previewer, only: :create
  end

  # Redirect from old users url to the new
  get "/users/:id", to: redirect('neighbors/%{id}')

  # Temporary Routes
  get '/projects/57/video_embed', to: redirect('projects/ideagarden/video_embed')

  get "/set_email" => "users#set_email", as: :set_email_users
  get "/:id", to: redirect('projects/%{id}')
end
