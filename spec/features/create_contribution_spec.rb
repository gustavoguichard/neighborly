require 'spec_helper'

feature 'Create contribution' do
  background do
    @project = create(:project, state: 'online', online_date: -1.seconds.from_now)
    @user = create(:user, password: 'test123')
    login
  end

  scenario 'providing value smaller then accepted' do
    visit project_path(@project)
    within '.sidebar' do
      click_on 'Contribute'
    end

    fill_in 'contribution_form_value', with: 9

    expect {
      click_on 'Review & Proceed'
    }.to_not change(Contribution, :count)
  end

  scenario 'providing value accepted' do
    visit project_path(@project)
    within '.sidebar' do
      click_on 'Contribute'
    end

    fill_in 'contribution_form_value', with: 10

    expect {
      click_on 'Review & Proceed'
    }.to change(Contribution, :count).by(1)
  end
end
