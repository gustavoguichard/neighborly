require 'spec_helper'

describe ContactsController do
  render_views

  describe '#new' do
    it 'returns a success http status' do
      get :new
      expect(response).to be_success
    end
  end

  describe '#create' do
    let(:contact_params) { { contact: { first_name: 'Foo',
                                last_name: 'Bar',
                                email: 'foo@bar.com',
                                company_name: 'Foo Bar CO.' } } }

    it 'creates a contact record' do
      expect{ post :create, contact_params }.to change{ Contact.count }.from(0).to(1)
    end

    it 'redirects to back' do
      post :create, contact_params
      expect(response).to redirect_to(contact_path)
    end

    it 'adds a flash notice' do
      post :create, contact_params
      expect(flash.notice[:message]).not_to be_empty
      expect(flash.notice[:dismissible]).to eq false
    end

    it 'does not create a new contact record' do
      expect {
        post :create, contact: { }
      }.not_to change{ Contact.count }
    end
  end
end
