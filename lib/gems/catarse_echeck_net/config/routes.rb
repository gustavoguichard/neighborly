CatarseEcheckNet::Engine.routes.draw do
  resources :echeck_net, only: [], path: 'payment/echeck_net' do
    collection do
      post :ipn
      get :check_routing_number
    end

    member do
      get :review
      post :pay
      get :success
      get :cancel
    end
  end
end
