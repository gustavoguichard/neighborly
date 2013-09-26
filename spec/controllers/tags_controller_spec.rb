require 'spec_helper'

describe TagsController do
  describe '#index' do
    before { get :index, term: '' }
    it { expect(response).to be_success }
  end
end
