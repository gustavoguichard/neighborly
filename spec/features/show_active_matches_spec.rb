require 'spec_helper'

feature 'Show active matches in project page' do
  background do
    @project = create(:project, state: 'online', online_date: -1.day.from_now)
    create(:match, project: @project, state: :pending)

    create(:match,
           project: @project,
           user: create(:user, name: 'Neighbor.ly'),
           state: :confirmed,
           value: 3_000,
           value_unit: 2,
           starts_at: Date.today,
           finishes_at: 3.days.from_now)

    create(:match,
           project: @project,
           user: create(:user, name: 'Foo Bar Corporation'),
           state: :confirmed,
           value: 1_000,
           value_unit: 5,
           starts_at: Date.today,
           finishes_at: 2.days.from_now)
  end

  scenario 'lists the active matches' do
    visit project_path(@project)
    expect(page).to have_text("Neighbor.ly has pledged to contribute $2 for every $1 raised up to $3,000")
    expect(page).to have_text("Foo Bar Corporation has pledged to contribute $5 for every $1 raised up to $1,000")
  end

  scenario 'show summary of active matches' do
    visit project_path(@project)
    expect(page).to have_text("Your $1 is worth $8 from now until #{I18n.l(2.days.from_now.to_date, format: :long)}")
  end
end
