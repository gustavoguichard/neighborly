require 'spec_helper'

def submit_project
  FactoryGirl.create(:category, name: 'Streetscapes')

  visit '/start'
  click_on 'Get Started'
  select 'Streetscapes', from: 'Project Category'
  fill_in 'Project Title', with: 'Three Points Beautification'
  select 'General obligation', from: 'Credit type'
  fill_in 'Project Budget', with: '1000000'
  fill_in 'Street Address', with: '4000'
  fill_in 'City, State', with: 'Louisville, KY'
  fill_in 'Statement file URL', with: 'http://example.com/statement.pdf'
  fill_in 'Summary', with: 'Making the intersection where Schnitzelburg, Shelby Park, & German-Paristown connect a better place to meet, walk, & drive through!'
  fill_in 'The Story', with: <<-THE_STORY
    # A Dreary Intersection

    If you pass through the intersection of Goss Avenue and Logan Street, what feels like a dozen times a day to us, you probably think “Geez, what an ugly intersection” a dozen times a day.  If you’re a Germantowner, you’re most likely to use this intersection to go downtown. If you’re a Shelby Parker, this is your gateway to Kroger.  Wherever your destination, you’re most likely using this intersection at some point in your day.
  THE_STORY
  select 'Neighborhood Organization', from: 'Organization type'

  click_on 'Submit Project'
end

feature 'Submit project' do
  background do
    @user = create(:user, password: 'test123')
    login
  end

  scenario 'propose project' do
    expect {
      submit_project
    }.to change(Project, :count).by(1)

    expect(page).to have_content('Successfully Submitted!')
  end

  scenario 'approve project' do
    submit_project
    logout

    Project.all.map(&:approve)

    visit '/'
    click_on 'Discover'
    expect(page).to have_content('Three Points Beautification')
  end
end
