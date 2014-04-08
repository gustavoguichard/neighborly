require 'spec_helper'

describe AuthorizationPolicy do
  subject { described_class }

  let(:policy) { described_class.new(user, authorization) }
  let(:user) { nil }
  let(:authorization) { create(:authorization) }

  permissions :destroy? do
    it 'should deny access if current user is nil' do
      expect(subject).not_to permit(nil, authorization)
    end

    it 'should deny access if user is not the owner' do
      expect(subject).not_to permit(User.new, authorization)
    end

    it 'should permit access if user is the owner' do
      new_user = authorization.user
      expect(subject).to permit(new_user, authorization)
    end

    it 'should permit access if user is admin' do
      admin = build(:user, admin: true)
      expect(subject).to permit(admin, authorization)
    end
  end
end
