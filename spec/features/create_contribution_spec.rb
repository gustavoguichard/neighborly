require 'spec_helper'

feature 'Create Investment' do
  background do
    @project = create(:project, :with_rewards)
    @user = create(:user, password: 'test123')
    login
  end

  scenario 'providing order size' do
    visit project_path(@project)
    click_on 'Invest'

    find(:xpath, "//input[@id='contribution_value']").set '10'

    expect {
      click_on 'Review & Proceed'
    }.to change(Contribution, :count).by(1)
  end
end
