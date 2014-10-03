require 'spec_helper'

feature 'User sign up' do
  scenario 'redirect to the last page after login', js: true do
    @project = create(:project)
    visit project_path(@project)
    login

    expect(current_path).to eql(project_path(@project))
  end

  scenario 'via home page and without providing password' do
    visit '/'
    expect(page).to have_link('Log in')

    fill_in 'Email', with: 'mr.watson@example.com'
    click_on 'Sign Up for early access'

    visit '/'
    expect(page).to_not have_link('Log in')
  end
end
