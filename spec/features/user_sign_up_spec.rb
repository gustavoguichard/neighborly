require 'spec_helper'

feature 'User sign up' do
  scenario 'redirect to the last page after login', js: true do
    @project = create(:project)
    visit user_my_spot_path(current_user)
    login

    expect(current_path).to eql(user_my_spot_path(current_user))
  end

  scenario 'via home page and without providing password' do
    visit '/'
    expect(page).to have_link('Log in')

    within '.home-page' do
      fill_in 'Email', with: 'mr.watson@example.com'
      click_on 'Sign Up for early access'
    end

    expect(page).to have_content('open the link to activate your account')
  end
end
