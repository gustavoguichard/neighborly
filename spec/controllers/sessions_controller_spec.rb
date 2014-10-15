require 'spec_helper'

describe SessionsController do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET new' do
    it 'makes csrf token available via header' do
      get :new
      expect(response.headers['X-Csrf-Token']).to_not be_empty
    end
  end
end
