CatarseCreditCardNet::Engine.routes.draw do
  resources :credit_card_net, only: [], path: 'payment/credit_card_net' do
    collection do
      post :ipn
    end

    member do
      get :review
      post :pay
      get :success
      get :cancel
    end
  end
end
