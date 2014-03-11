# coding: utf-8

require 'spec_helper'

describe "Projects" do
  let(:project){ build(:project) }

  before {
    ProjectsController.any_instance.stub(:last_tweets).and_return([])
    ::Configuration[:base_url] = 'http://neighbor.ly'
    ::Configuration[:company_name] = 'Neighbor.ly'
  }

  describe "home" do
    before do
      create(:project, state: 'online', recommended: true, online_days: 30, online_date: Time.now, home_page: true)
      create(:project, state: 'online', featured: true, online_days: 30, online_date: Time.now)
      create(:project, state: 'soon', online_days: 30, home_page: true)
      create(:project, state: 'online', online_days: 30, online_date: 29.days.ago, home_page: true)
      visit root_path
    end

    it "should show recommended project" do
      recommended = all(".recommended .project-box:not(.large)")
      recommended.should have(1).items
    end

    it "should show featured project" do
      featured = all(".recommended .project-box.large")
      featured.should have(1).items
    end

    it "should show coming soon projects" do
      coming_soon = all(".coming-soon .project-box")
      coming_soon.should have(1).items
    end

    it "should show ending soon projects" do
      ending_soon = all(".ending-soon .project-box")
      ending_soon.should have(1).items
    end
  end

  describe "new and create" do
    before do
      Capybara.default_selector = :css
      project # need to build the project to create category before visiting the page
      login
      visit new_project_path
      sleep 1
    end

    it "should present the form and save the data" do
      all("form#new_project").should have(1).items
      within "form#new_project" do
        select(project.category.to_s, from: 'project[category_id]')
        select(I18n.t("project.organization_type.#{Project.organization_types.first}"), from: 'project[organization_type]')
        ['name', 'goal', 'address', 'headline', 'about'].each do |a|
          fill_in "project_#{a}", with: project.attributes[a]
        end
        find('input[type=submit]').click
      end
    end
  end

  describe "edit" do
    let(:project) { create(:project, online_days: 10, state: 'online', user: current_user) }

    before do
      login
      visit project_path(project)
    end

    it 'edit tab should be present' do
      page.should have_selector("a[href='#{edit_project_path(project)}']")
    end
  end

  describe "budget" do
    let(:project) { create(:project, online_days: 10, state: 'online', user: current_user, budget: 'some budget') }

    before do
      login
      visit project_path(project)
    end

    it 'budget tab should be present' do
      page.should have_selector("a[href='#{budget_project_path(project)}']")
    end
  end

  describe "tabs" do
    before do
      create(:contribution, project: project, state: 'confirmed', user: project.user)
      login
      visit project_path(project)
    end

   context 'when is my project' do
      let(:project) { create(:project, online_days: 10, state: 'online', user: current_user) }

      describe '#updates' do
        it 'should be able to click on updates tab' do
           find("a[href='#{project_updates_path(project)}']").click
           current_path.should == project_updates_path(project)
        end
      end

      describe '#contributions' do
        it 'should be able to click on contributions tab' do
          within 'nav.tabs' do
            find("a[href='#{project_contributions_path(project)}']").click
            current_path.should == project_contributions_path(project)
          end
        end
      end

      describe '#comments' do
        it 'should be able to click on comments tab' do
           find("a[href='#{comments_project_path(project)}']").click
           current_path.should == comments_project_path(project)
        end
      end

      describe '#faqs' do
        it 'should be able to click on faqs tab' do
           find("a[href='#{project_faqs_path(project)}']").click
           current_path.should == project_faqs_path(project)
        end
      end

      describe '#terms' do
        it 'should be able to click on terms tab' do
           find("a[href='#{project_terms_path(project)}']").click
           current_path.should == project_terms_path(project)
        end
      end

      describe '#reports' do
        it 'should be able to click on reports tab' do
           find("a[href='#{reports_project_path(project)}']").click
           current_path.should == reports_project_path(project)
        end
      end
    end

    context 'when is not my project' do
      let(:project) { create(:project, online_days: 10, state: 'online') }

      it 'should not have reports tab' do
        page.should_not have_selector("a[href='#{reports_project_path(project)}']")
      end

      it 'should not have edit link' do
        page.should_not have_selector("a[href='#{edit_project_path(project)}']")
      end
    end
  end
end
