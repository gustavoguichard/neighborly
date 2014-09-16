require 'spec_helper'

describe Activity do
  describe 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :happened_at }
    it { should validate_presence_of :user }
    it { should validate_presence_of :project }
    it { should ensure_length_of(:summary).is_at_most(140) }

    it 'allow empty summary' do
      should allow_value('').for(:summary)
    end
  end

  describe 'associations' do
    it { should belong_to :project }
    it { should belong_to :user }
  end
end
