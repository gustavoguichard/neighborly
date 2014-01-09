require 'spec_helper'

describe Projects::TermsController do
  let(:document) { create(:project_document) }
  let(:file) { File.open("#{Rails.root}/spec/fixtures/image.png") }
  let(:current_user) { nil }

  before do
    controller.stub(:current_user).and_return(current_user)
  end

  subject { response }

  describe "POST create" do
    before{ post :create, project_id: document.project, locale: 'en', project_document: { name: 'some name', document: file } }

    subject { ProjectDocument.where(project_id: document.project) }

    context 'When user is a guest' do
      it{ should have(1).item }
    end

    context "When user is a registered user but don't the project owner" do
      let(:current_user){ create(:user) }
      it{ should have(1).item }
    end

    context 'When user is admin' do
      let(:current_user) { create(:user, admin: true) }
      it{ should have(2).itens }
    end

    context 'When user is project_owner' do
      let(:current_user) { document.project.user }
      it{ should have(2).itens }
    end
  end

  describe "DELETE destroy" do
    before { delete :destroy, project_id: document.project, id: document, locale: 'en' }
    let(:total_documents) { ProjectDocument.where(project_id: document.project) }

    context 'When user is a guest' do
      its(:status) { should == 302 }
      it { total_documents.should have(1).item }
    end

    context "When user is a registered user but don't the project owner" do
      let(:current_user){ create(:user) }
      its(:status) { should == 302 }
      it { total_documents.should have(1).item }
    end

    context 'When user is admin' do
      let(:current_user) { create(:user, admin: true) }
      its(:status) { should == 302 }
      it { total_documents.should have(0).item }
    end

    context 'When user is project_owner' do
      let(:current_user) { document.project.user }
      its(:status) { should == 302 }
      it { total_documents.should have(0).item }
    end
  end


end
