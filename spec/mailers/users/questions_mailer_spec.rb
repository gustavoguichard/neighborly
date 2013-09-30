require "spec_helper"

describe Users::QuestionsMailer do
  let(:project) { create(:project) }
  let(:user) { project.user }
  let(:current_user) { create(:user) }
  let(:mail) { Users::QuestionsMailer.new('some question', user, project, current_user) }

  it 'renders the subject' do
    expect(mail.subject).to eq "Question Regarding #{project.name}."
  end

  it 'renders the receiver email' do
    expect(mail.to).to eq [user.email]
  end

  it 'renders the reply to email' do
    expect(mail.reply_to).to eq [current_user.email]
  end

  it 'assigns @user.name' do
    expect(mail.body.encoded).to match(user.display_name)
  end

  it 'assigns @question' do
    expect(mail.body.encoded).to match('some question')
  end

end
