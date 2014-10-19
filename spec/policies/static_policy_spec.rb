require 'spec_helper'

describe StaticPolicy do
  subject{ described_class }

  permissions :faq? do
    it 'does not permit access if user is nil' do
      expect(subject).not_to permit(nil, :static)
    end

    it 'does not permit access if user is not mvp beta acessor' do
      expect(subject).not_to permit(User.new, :static)
    end

    it 'permits access if user is mvp beta acessor' do
      expect(subject).to permit(build(:user, :beta), :static)
    end
  end
end
