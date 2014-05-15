require 'spec_helper'

class Project < ActiveRecord::Base
  include Shared::Notifiable
end

describe Shared::Notifiable do
  let(:project) { create(:project) }
  subject       { project }

  it { should have_many :notifications }

  describe '#notify_owner' do
    context 'with no extra params' do
      it 'creates a notification' do
        expect(Notification).to receive(:notify_once).with(
          :testing,
          project.user,
          { project_id: project.id },
          { project: project }
        )

        project.notify_owner(:testing)
      end
    end

    context 'with extra params' do
      it 'creates a notification' do
        expect(Notification).to receive(:notify_once).with(
          :testing,
          project.user,
          { project_id: project.id, filter_id: 1 },
          { project: project, option: 2 }
        )

        project.notify_owner(:testing,
                            { filter_id: 1 },
                            { option: 2 })
      end
    end
  end
end
