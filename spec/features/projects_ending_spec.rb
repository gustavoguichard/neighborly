require 'spec_helper'

feature 'Project\'s ending' do
  include ActiveSupport::Testing::TimeHelpers

  background do
    @project = create(:project, state: 'online', online_date: -1.seconds.from_now)
    @user = create(:user, password: 'test123')
    login
  end

  scenario 'After reaching ending date' do
    @project.finish

    travel (@project.online_days + 1).days do
      visit '/'
      click_on 'Discover'
      click_on @project.name
      expect(page).to_not have_link('Contribute')
    end
  end
end
