require 'sidekiq/web'

Catarse::Application.routes.draw do

  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)

  devise_for :users, path: '',
    path_names:   { sign_in: :login, sign_out: :logout, sign_up: :sign_up },
    controllers:  { omniauth_callbacks: :omniauth_callbacks }


  devise_scope :user do
    post '/sign_up', to: 'devise/registrations#create', as: :sign_up
  end

  get '/thank_you' => "static#thank_you"

  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }

  # Mountable engines
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount CatarseCreditCardNet::Engine => "/", as: :catarse_credit_card_net
  mount CatarseEcheckNet::Engine => "/", as: :catarse_echeck_net
  mount CatarsePaypalExpress::Engine => "/", as: :catarse_paypal_express
  #mount CatarseMoip::Engine => "/", as: :catarse_moip

  # Non production routes
  if Rails.env.development?
    resources :emails, only: [ :index, :show ]
  end

  # Channels
  constraints subdomain: /^(?!www|secure|test|local|staging)(\w+)/ do
    namespace :channels, path: '' do
      get '/', to: 'profiles#show', as: :profile
      resources :channels_subscribers, only: [:index, :create, :destroy]

      namespace :admin do

        get '/', to: 'dashboard#index', as: :dashboard

        namespace :reports do
          resources :subscriber_reports, only: [ :index ]
        end

        resources :followers, only: [ :index ]

        resources :projects, only: [ :index, :update] do
          member do
            put 'approve'
            put 'reject'
            put 'push_to_draft'
            put 'push_to_soon'
          end
        end
      end

      resource :profile
      resources :projects, only: [:new, :create] do
        collection do
          get 'video'
        end
      end
      # NOTE We use index instead of create to subscribe comming back from auth via GET
      resource :channels_subscriber, only: [:show, :destroy], as: :subscriber
    end
  end

  # Root path should be after channel constraints
  root to: 'projects#index'

  # Static Pages
  get '/sitemap',               to: 'static#sitemap',             as: :sitemap
  get '/how-it-works',          to: 'static#how_it_works',        as: :how_it_works
  get "/about",                 to: "static#about",               as: :about
  get "/faq",                   to: "static#faq",                 as: :faq
  get "/terms",                 to: "static#terms",               as: :terms
  get "/privacy",               to: "static#privacy",             as: :privacy

  #get "/guidelines_backers",    to: "static#guidelines_backers",  as: :guidelines_backers
  get "/start",                 to: "static#start",               as: :start
  get "/start/terms",           to: "static#start_terms",         as: :start_terms


  get "/discover/(:filter)(/near/:near)(/category/:category)(/tags/:tags)(/search/:search)", to: "discover#index", as: :discover

  resources :tags, only: [:index]

  namespace :reports do
    resources :backer_reports_for_project_owners, only: [:index]
  end

  # Temporary
  get '/projects/neuse-river-greenway-benches-draft', to: redirect('/projects/neuse-river-greenway-benches')

  resources :projects, except: [ :destroy ] do
    resources :faqs, controller: 'projects/faqs', only: [ :index, :create, :destroy ]
    resources :terms, controller: 'projects/terms', only: [ :index, :create, :destroy ]
    resources :updates, controller: 'projects/updates', only: [ :index, :create, :destroy ]

    collection do
      get :near
      get 'video'
    end

    member do
      post :send_reward_email
      put 'pay'
      get 'embed'
      get 'video_embed'
      get 'embed_panel'
      get 'comments'
      get 'reports'
      get 'budget'
      get 'reward_contact'
      get 'success'
      get 'send_to_analysis'
    end

    resources :rewards, only: [ :index, :create, :update, :destroy, :new, :edit ] do
      member do
        post 'sort'
      end
    end

    resources :backers, controller: 'projects/backers' do
      member do
        put 'credits_checkout'
      end
    end
  end

  resources :users do
    resources :questions, controller: 'users/questions', only: [:new, :create]
    resources :projects, controller: 'users/projects', only: [ :index ]
    resources :backers, controller: 'users/backers', only: [:index] do
      member do
        get :request_refund
      end
    end

    resources :authorizations, controller: 'users/authorizations', only: [:destroy]
    resources :unsubscribes, only: [:create]
    member do
      get :profile,   to: 'users#edit'
      get :settings
      get :credits
      get :edit
      put 'unsubscribe_update'
      put 'update_email'
      put 'update_password'
    end
  end

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :tags, except: [:show]
    resources :press_assets, except: [:show]
    resources :financials, only: [ :index ]
    resources :users, only: [ :index ]

    resources :channels, except: [:show] do
      member do
        put 'push_to_draft'
        put 'push_to_online'
      end

      resources :owners, only: [:index, :new, :create, :destroy], controller: 'channels/owners'
    end

    resources :projects, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        put 'reject'
        put 'push_to_draft'
        put 'push_to_soon'
        get 'populate_backer'
        post 'populate'
      end
    end

    resources :backers, only: [ :index, :update ] do
      member do
        put 'confirm'
        put 'pendent'
        put 'change_reward'
        put 'refund'
        put 'hide'
        put 'cancel'
        put 'push_to_trash'
      end
    end

    namespace :reports do
      resources :backer_reports, only: [ :index ]
      resources :funding_raised_per_project_reports, only: [ :index ]
      resources :statistics, only: [ :index ]
    end
  end

  get "/set_email" => "users#set_email", as: :set_email_users
  get "/:id", to: redirect('projects/%{id}')
end
