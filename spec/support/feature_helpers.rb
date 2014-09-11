module FeatureHelpers
  def login
    visit new_user_session_path

    within ".login-box" do
      fill_in 'user_email', with: current_user.email
      fill_in 'user_password', with: 'test123'
      find('input.button').click
    end
  end

  def current_user
    @user ||= FactoryGirl.create(:user, password: 'test123', password_confirmation: 'test123')
  end

  def logout
    within '.top-bar' do
      click_on 'Log out'
    end
  end

  def login_admin
    visit '/dashboard'

    admin = FactoryGirl.create(:user, admin: true, password: '123123123', password_confirmation: '123123123')
    find(:css, 'placeholder="Email"').set(admin.email)
    find(:css, 'placeholder="Password"').set('123123123')
    click_in 'Sign me in'
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
end
