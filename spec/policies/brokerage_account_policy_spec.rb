require 'spec_helper'

describe BrokerageAccountPolicy do
  subject { described_class }

  permissions :new? do
    it 'permits access from signed in mvp beta user' do
      should permit(build(:user, :beta), subject)
    end

    it 'denies access from signed in normal user' do
      should_not permit(User.new, subject)
    end

    it 'denies access not signed in users' do
      should_not permit(nil, subject)
    end
  end

  permissions :create? do
    it 'permits access from signed in mvp beta user' do
      should permit(build(:user, :beta), subject)
    end

    it 'denies access from signed in normal user' do
      should_not permit(User.new, subject)
    end

    it 'denies access not signed in users' do
      should_not permit(nil, subject)
    end
  end

  permissions :edit? do
    it 'permits access from signed in mvp beta user' do
      should permit(build(:user, :beta), subject)
    end

    it 'denies access from signed in normal user' do
      should_not permit(User.new, subject)
    end

    it 'denies access not signed in users' do
      should_not permit(nil, subject)
    end
  end

  permissions :update? do
    it 'permits access from signed in mvp beta user' do
      should permit(build(:user, :beta), subject)
    end

    it 'denies access from signed in normal user' do
      should_not permit(User.new, subject)
    end

    it 'denies access not signed in users' do
      should_not permit(nil, subject)
    end
  end
end
