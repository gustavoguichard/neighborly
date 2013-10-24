require 'spec_helper'

describe Projects::FaqsController do
  let(:faq) { create(:project_faq) }
  let(:current_user) { nil }

  before do
    controller.stub(:current_user).and_return(current_user)
  end

  subject { response }

  describe "POST create" do
    before{ post :create, project_id: faq.project, locale: 'en', project_faq: {title: 'title', answer: 'answer'} }

    subject { ProjectFaq.where(project_id: faq.project) }

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
      let(:current_user) { faq.project.user }
      it{ should have(2).itens }
    end
  end

  describe "DELETE destroy" do
    before { delete :destroy, project_id: faq.project, id: faq.id, locale: 'en' }
    let(:total_faqs) { ProjectFaq.where(project_id: faq.project) }

    context 'When user is a guest' do
      its(:status) { should == 302 }
      it { total_faqs.should have(1).item }
    end

    context "When user is a registered user but don't the project owner" do
      let(:current_user){ create(:user) }
      its(:status) { should == 302 }
      it { total_faqs.should have(1).item }
    end

    context 'When user is admin' do
      let(:current_user) { create(:user, admin: true) }
      its(:status) { should == 302 }
      it { total_faqs.should have(0).item }
    end

    context 'When user is project_owner' do
      let(:current_user) { faq.project.user }
      its(:status) { should == 302 }
      it { total_faqs.should have(0).item }
    end
  end


end
