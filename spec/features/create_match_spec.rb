require 'spec_helper'

feature 'Create match' do
  background do
    @project = create(:project, state: 'online', online_date: -1.seconds.from_now)
    login
  end

  scenario 'generate new' do
    visit project_path(@project)
    click_on 'Match'

    fill_in 'projects_challenges_match_value',         with: 2
    fill_in 'projects_challenges_match_starts_at',     with: 1.day.from_now.strftime('%m/%d/%y')
    fill_in 'projects_challenges_match_finishes_at',   with: 3.days.from_now.strftime('%m/%d/%y')
    fill_in 'projects_challenges_match_maximum_value', with: 20_000
    expect {
      click_on 'Preview your match'
    }.to change(Projects::Challenges::Match, :count).by(1)
  end
end
