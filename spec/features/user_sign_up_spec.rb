require 'spec_helper'

feature 'User sign up', js: true do
  scenario 'redirect to the last page after login' do
    @project = create(:project)
    visit project_path(@project)
    login

    expect(current_path).to eql(project_path(@project))
  end
end
