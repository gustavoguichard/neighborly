require 'spec_helper'

describe OrganizationObserver do
  let(:organization) { create(:organization) }

  describe '#after_commit' do
    it 'calls Webhook::EventRegister' do
      expect(Webhook::EventRegister).to receive(:new).with(organization, created: true)
      organization.run_callbacks(:commit)
    end
  end
end
