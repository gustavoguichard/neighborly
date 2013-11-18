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
        foundation_select(project.category.to_s, from: 'project[category_id]')
        ['name', 'goal', 'address', 'headline', 'about'].each do |a|
          fill_in "project_#{a}", with: project.attributes[a]
        end
        find('label[for=project_accepted_terms]').click
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
    let(:project) { create(:project, online_days: 10, state: 'online', user: current_user) }

    before do
      login
      visit project_path(project)
    end

    it 'updates tab should be present' do
      page.should have_selector("a[href='#{project_updates_path(project)}']")
    end

    it 'backers tab should be present' do
      page.should have_selector("a[href='#{project_backers_path(project)}']")
    end

    it 'comments tab should be present' do
      page.should have_selector("a[href='#{comments_project_path(project)}']")
    end

    it 'faqs tab should be present' do
      page.should have_selector("a[href='#{project_faqs_path(project)}']")
    end

    it 'terms tab should be present' do
      page.should have_selector("a[href='#{project_terms_path(project)}']")
    end
  end
end
