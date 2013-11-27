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
end

module CustomFormsHelper
  def foundation_select(option, opts={})
    # Zurb Foundation adds custom markup after (and then hides)
    # the originating select. Here we simulate the user's interaction
    # with the custom form instead of just setting the hidden originating select's value
    originating_select_name = opts[:from]

    custom_select = find("select[name='#{originating_select_name}'] + .custom.dropdown")
    # click dropdown trigger
    custom_select.find('a.selector').click
    # click option li with correct option text
    custom_select.find('li', text: option).click
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
  config.include CustomFormsHelper, type: :feature
end
