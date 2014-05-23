require 'spec_helper'

describe Match do
  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
    it { should have_many(:payment_notifications) }
    it { should have_many(:matchings) }
    it do
      should have_many(:matched_contributions).through(:matchings).
                                               source(:contribution)
    end
  end

  describe 'validations' do
    it { should validate_numericality_of(:value).is_greater_than_or_equal_to(1_000) }

    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:user) }

    describe 'start and finish dates' do
      it 'returns error with starts_at before current date' do
        subject.starts_at = -1.day.from_now
        expect(subject).to have(1).errors_on(:starts_at)
      end

      it 'returns no errors with starts_at between current_date and project\'s expiration date' do
        project = Project.new
        project.stub(:expires_at).and_return(10.days.from_now)
        subject.project   = project

        subject.starts_at   = project.expires_at - 3.days
        subject.finishes_at = subject.starts_at + 1.day
        expect(subject).to have(:no).errors_on(:starts_at)
      end

      it 'returns error with finishes_at before starts_at' do
        subject.starts_at   = 5.days.from_now
        subject.finishes_at = 1.day.from_now
        expect(subject).to have(1).errors_on(:finishes_at)
      end

      it 'returns error with finishes_at after project\'s expiration date' do
        project = Project.new
        project.stub(:expires_at).and_return(2.days.from_now)
        subject.project     = project

        subject.finishes_at = project.expires_at + 3.days
        subject.starts_at   = project.expires_at + 1.day
        expect(subject).to have(1).errors_on(:finishes_at)
      end

      it 'returns no errors with finishes_at between starts_at and project\'s expiration date' do
        project = Project.new
        project.stub(:expires_at).and_return(10.days.from_now)
        subject.project   = project

        subject.starts_at   = project.expires_at - 8.days
        subject.finishes_at = subject.starts_at + 1.day
        expect(subject).to have(:no).errors_on(:finishes_at)
      end
    end
  end

  describe 'scopes' do
    describe 'active' do
      let(:match) { create(:match) }

      it 'excludes those not yet started' do
        match = create(:match, starts_at: 2.days.from_now, finishes_at: 3.days.from_now)
        expect(described_class.active).to_not include(match)
      end

      it 'excludes those already finished' do
        match = build(:match, starts_at: -5.days.from_now, finishes_at: -3.days.from_now)
        match.save(validate: false)
        expect(described_class.active).to_not include(match)
      end

      it 'excludes those with non confirmed state' do
        match = build(:match, starts_at: -5.days.from_now, finishes_at: -3.days.from_now, state: :pending)
        match.save(validate: false)
        expect(described_class.active).to_not include(match)
      end

      it 'uses UTC\'s day as definition of today for starts_at attribute' do
        current_time = Time.new(2014, 5, 10, 2, 0, 0, 5.hours)
        Time.stub(:now).and_return(current_time)
        Date.stub(:current).and_return(Date.new(2014, 5, 10))

        match = build(:match, starts_at: Date.current)
        match.save(validate: false)
        expect(described_class.active).to_not include(match)
      end
    end
  end

  describe 'pledged amount' do
    it 'sums matched contributions values' do
      subject = create(:match, value_unit: 2)
      create(:contribution, project: subject.project, value: 11)
      expect(subject.reload.pledged).to eql(22)
    end
  end
end
