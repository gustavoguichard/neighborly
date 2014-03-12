require 'spec_helper'

describe Concerns::PersistentWarnings do
  class MyController < ActionController::Base; end

  let(:flash)             { double('ActionDispatch::Flash', notice: nil, alert: nil) }
  let(:current_user)      { stub_model(User) }
  let(:is_user_signed_in) { true }
  before(:all) do
    MyController.include(described_class)
  end
  subject { MyController.new }
  before do
    subject.stub(:current_user).and_return(current_user)
    subject.stub(:user_signed_in?).and_return(is_user_signed_in)
    subject.stub(:flash).and_return(flash)
    subject.stub(:url_for)
  end

  describe 'setter of warning with highest priority' do
    it 'sets notice flash with the warning when one exists' do
      subject.stub(:persistent_warning).and_return(nil)
      expect(flash).to_not receive(:notice=)
      subject.set_persistent_warning
    end

    it 'sets notice flash with the warning when one is available' do
      subject.stub(:persistent_warning).and_return('foobar')
      expect(flash).to receive(:notice=).with('foobar')
      subject.set_persistent_warning
    end
  end

  describe 'current persistent warning' do
    context 'signed in' do
      context 'with unconfirmed account' do
        before do
          current_user.stub(:confirmed?).and_return(false)
        end

        context 'with completed profile' do
          before do
            current_user.stub_chain(:completeness_progress, :to_i).and_return(100)
          end

          it 'shows message asking to confirm account' do
            link    = 'http://example.com'
            subject.stub(:new_user_confirmation_path).and_return(link)
            warning = I18n.t('devise.confirmations.confirm', link: link)
            expect(subject.persistent_warning[:message]).to eql(warning)
          end
        end

        context 'with uncomplete profile' do
          before do
            current_user.stub_chain(:completeness_progress, :to_i).and_return(99)
          end

          it 'shows message asking to confirm account' do
            link    = 'http://example.com'
            subject.stub(:new_user_confirmation_path).and_return(link)
            warning = I18n.t('devise.confirmations.confirm', link: link)
            expect(subject.persistent_warning[:message]).to eql(warning)
          end
        end
      end

      context 'with confirmed account' do
        before do
          current_user.stub(:confirmed?).and_return(true)
        end

        context 'with completed profile' do
          before do
            current_user.stub_chain(:completeness_progress, :to_i).and_return(100)
          end

          it 'returns no warning' do
            expect(subject.persistent_warning).to be_nil
          end
        end

        context 'with uncomplete profile' do
          before do
            current_user.stub_chain(:completeness_progress, :to_i).and_return(99)
          end

          it 'shows message asking to complete profile' do
            link    = 'http://example.com'
            subject.stub(:edit_user_path).and_return(link)
            warning = I18n.t('controllers.users.completeness_progress', link: link)
            expect(subject.persistent_warning[:message]).to eql(warning)
          end
        end
      end
    end

    context 'not signed in' do
      let(:is_user_signed_in) { false }
      let(:current_user)      { nil }

      it 'returns no warning' do
        expect(subject.persistent_warning).to be_nil
      end
    end
  end
end
