require 'spec_helper'

describe BrokerageAccountPolicy do
  subject { described_class }

  permissions :new? do
    it 'permits access from signed in user' do
      should permit(User.new, subject)
    end

    it 'denies access not signed in users' do
      should_not permit(nil, subject)
    end
  end

  permissions :create? do
    it 'permits access from signed in user' do
      should permit(User.new, subject)
    end

    it 'denies access not signed in users' do
      should_not permit(nil, subject)
    end
  end

  permissions :edit? do
    it 'permits access from signed in user' do
      should permit(User.new, subject)
    end

    it 'denies access not signed in users' do
      should_not permit(nil, subject)
    end
  end

  permissions :update? do
    it 'permits access from signed in user' do
      should permit(User.new, subject)
    end

    it 'denies access not signed in users' do
      should_not permit(nil, subject)
    end
  end
end
