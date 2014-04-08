require 'spec_helper'

describe Projects::ContributionsController do
  render_views
  let(:project) { create(:project) }
  let(:contribution){ create(:contribution, value: 10.00, credits: true, project: project, state: 'pending') }
  let(:user){ nil }
  let(:contribution_info){ { address_city: 'Porto Alegre', address_complement: '24', address_neighborhood: 'Rio Branco', address_number: '1004', address_phone_number: '(51)2112-8397', address_state: 'RS', address_street: 'Rua Mariante', address_zip_code: '90430-180', payer_email: 'diogo@biazus.me', payer_name: 'Diogo de Oliveira Biazus' } }

  subject{ response }

  before do
    controller.stub(:current_user).and_return(user)
  end

  describe "PUT credits_checkout" do
    let(:failed_project) { create(:project, state: 'online') }
    before do
      put :credits_checkout, { locale: :pt, project_id: project, id: contribution.id }
    end

    context "without user" do
      it{ should redirect_to(new_user_session_path) }
    end

    context "when contribution don't exist in current_user" do
      let(:user){ create(:user) }
      it{ should redirect_to(root_path) }
      it 'should set alert flash' do
        request.flash.alert.should_not be_empty
      end
    end

    context "with correct user but insufficient credits" do
      let(:user){ contribution.user }
      it('should not confirm contribution'){ contribution.reload.confirmed?.should be_false }
      it('should set flash failure'){ request.flash.alert.should == I18n.t('controllers.projects.contributions.credits_checkout.no_credits') }
      it{ should redirect_to(new_project_contribution_path(project)) }
    end

    context "with correct user and sufficient credits" do
      let(:user) do
        create(:contribution, value: 10.00, credits: false, state: 'confirmed', user: contribution.user, project: failed_project)
        failed_project.update_attributes state: 'failed'
        contribution.user.reload
        contribution.user
      end

      it('should confirm contribution') { contribution.reload.confirmed?.should be_true }
      it'should set notice flash' do
        request.flash.notice.should == I18n.t('controllers.projects.contributions.credits_checkout.success')
      end
      it { should redirect_to(project_contribution_path(project, contribution.id)) }
    end
  end

  describe "GET edit" do
    before do
      request.env['REQUEST_URI'] = "/test_path"
      get :edit, {locale: :pt, project_id: project, id: contribution.id}
    end

    context "when no user is logged" do
      it{ should redirect_to new_user_session_path }
      it('should set the session[:return_to]'){ session[:return_to].should == "/test_path" }
    end

    context "when user is logged in" do
      let(:user){ create(:user) }
      let(:contribution){ create(:contribution, value: 10.00, credits: true, project: project, state: 'pending', user: user) }
      its(:body){ should =~ /#{I18n.t('projects.contributions.edit.title', project_name: project.name)}/ }
      its(:body){ should =~ /#{project.name}/ }
      its(:body){ should =~ /\$10/ }
    end

    describe 'persistent warnings' do
      let(:set_expectations) do
        expect(controller).to_not receive(:set_persistent_warning)
      end

      it 'skips its setter method call' do
      end
    end
  end

  describe "POST create" do
    let(:value){ '20.00' }
    let(:set_expectations) {}
    before do
      request.env['REQUEST_URI'] = "/test_path"
      set_expectations
      post :create, {locale: :pt, project_id: project, contribution: { value: value, reward_id: nil, anonymous: '0' }}
    end

    context "when no user is logged" do
      it{ should redirect_to new_user_session_path }
      it('should set the session[:return_to]'){ session[:return_to].should == "/test_path" }
    end

    context "when user is logged in" do
      let(:user){ create(:user) }
      it{ should redirect_to edit_project_contribution_path(project_id: project, id: Contribution.last.id) }
    end

    context "without value" do
      let(:user){ create(:user) }
      let(:value){ '' }

      it{ should redirect_to new_project_contribution_path(project) }
    end

    context "with invalid contribution values" do
      let(:user){ create(:user) }
      let(:value) { 2.0 }

      it{ should redirect_to new_project_contribution_path(project) }
    end

    describe 'persistent warnings' do
      let(:set_expectations) do
        expect(controller).to_not receive(:set_persistent_warning)
      end

      it 'skips its setter method call' do
      end
    end
  end

  describe "GET new" do
    let(:secure_review_host){ nil }
    let(:user){ create(:user) }
    let(:online){ true }
    let(:browser){ double("browser", ie9?: false, modern?: true) }

    before do
      ::Configuration[:secure_review_host] = secure_review_host
      Project.any_instance.stub(:online?).and_return(online)
      get :new, {locale: :pt, project_id: project}
    end

    context "when no user is logged" do
      let(:user){ nil }
      it{ should redirect_to new_user_session_path }
    end

    context "when user is logged in but project.online? is false" do
      let(:online){ false }
      it{ should redirect_to root_path }
    end

    context "when project.online? is true and we have configured a secure create url" do
      let(:secure_review_host){ 'secure.catarse.me' }
      it "should assign the https url to @create_url" do
        assigns(:create_url).should == project_contributions_url(project, host: ::Configuration[:secure_review_host], protocol: 'https')
      end
    end

    context "when project.online? is true and we have not configured a secure create url" do
      it{ should render_template("projects/contributions/new") }
      it "should assign review_project_contributions_path to @create_url" do
        assigns(:create_url).should == project_contributions_path(project)
      end
      its(:body) { should =~ /#{I18n.t('projects.contributions.new.title')}/ }
      its(:body) { should =~ /#{I18n.t('controllers.projects.contributions.new.no_reward')}/ }
      its(:body) { should =~ /#{project.name}/ }
    end

    describe 'persistent warnings' do
      let(:set_expectations) do
        expect(controller).to_not receive(:set_persistent_warning)
      end

      it 'skips its setter method call' do
      end
    end
  end

  describe "GET show" do
    let(:contribution){ create(:contribution, value: 10.00, credits: false, state: 'confirmed') }
    before do
      get :show, { locale: :pt, project_id: contribution.project, id: contribution.id }
    end

    context "when no user is logged in" do
      it{ should redirect_to new_user_session_path }
    end

    context "when user logged in is different from contribution" do
      let(:user){ create(:user) }
      it{ should redirect_to root_path }
      it('should set flash failure'){ request.flash.alert.should_not be_empty }
    end

    context "when contribution is logged in" do
      let(:user){ contribution.user }
      it{ should be_successful }
      its(:body){ should =~ /#{I18n.t('projects.contributions.show.title')}/ }
    end
  end

  describe "GET index" do
    before do
      create(:contribution, value: 10.00, state: 'confirmed',
              reward: create(:reward, project: project, description: 'Test Reward'),
              project: project,
              user: create(:user, name: 'Foo Bar'))
      get :index, { locale: :pt, project_id: project }
    end
    its(:status){ should eq 200 }
  end
end
