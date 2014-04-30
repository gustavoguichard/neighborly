require 'spec_helper'

feature 'Create match' do
  background do
    @project = create(:project, state: 'online', online_date: -1.seconds.from_now)
    login
  end

  scenario 'generate new' do
    visit project_path(@project)
    click_on 'Match'

    fill_in 'match_value_unit',  with: 2
    fill_in 'match_starts_at',   with: 1.day.from_now.strftime('%m/%d/%y')
    fill_in 'match_finishes_at', with: 3.days.from_now.strftime('%m/%d/%y')
    fill_in 'match_value',       with: 20_000
    expect {
      click_on 'Preview your match'
    }.to change(Match, :count).by(1)
  end
end
