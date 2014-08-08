require 'spec_helper'

describe Match do
  include ActiveSupport::Testing::TimeHelpers

  let(:match) { create(:match) }

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
    it { should have_many(:matchings) }
    it do
      should have_many(:original_contributions).through(:matchings).
                                               source(:contribution)
    end
  end

  describe 'validations' do
    it { should validate_numericality_of(:value).is_greater_than_or_equal_to(500) }

    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:user) }

    it 'allow complete matches after its finish date' do
      match
      travel_to(10.days.from_now) do
        expect {
          match.complete!
        }.to change(Match.uncompleted, :count).by(-1)
      end
    end

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

      it 'includes those with no matched contributions yet' do
        match = create(:match, value: 1_000, value_unit: 1)
        expect(described_class.active).to include(match)
      end

      it 'includes those with remaining amount' do
        match = create(:match, value: 1_000, value_unit: 1)
        create(:contribution, project: match.project, value: 50, state: :confirmed)
        expect(described_class.active).to include(match)
      end

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

      it 'excludes those with no remaining amount' do
        match = create(:match, value: 1_000, value_unit: 1)
        create(:contribution, project: match.project, value: 1_000, state: :confirmed)
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

    describe 'activating_today' do
      it 'includes matches activating today' do
        match

        expect(described_class.activating_today).to include(match)
      end

      it 'excludes matches activated in previous days' do
        match = travel_to(10.days.ago) do
          create(:match, starts_at: 5.days.from_now)
        end

        expect(described_class.activating_today).to_not include(match)
      end

      it 'excludes matches activated in future days' do
        match = create(:match, starts_at: 5.days.from_now)

        expect(described_class.activating_today).to_not include(match)
      end
    end
  end

  describe '#matched_contributions' do
    subject { create(:match, value_unit: 2) }

    it 'returns the matched contribution' do
      original_contribution = create(:contribution,
                                     project: subject.project,
                                     value:   11)
      matched_contributions = Contribution.where(
        matching_id: original_contribution.matchings
      )
      expect(subject.matched_contributions).to include(matched_contributions.first)
    end

  end

  describe '#pledged' do
    subject { create(:match, value_unit: 2) }

    it 'sums matched contributions values' do
      create(:contribution, project: subject.project, value: 11)
      expect(subject.reload.pledged).to eql(22)
    end

    it 'skips contributions out of available_to_count scope' do
      create(:contribution, project: subject.project, value: 11, state: :canceled)
      Contribution.stub(:available_to_count).and_return(Contribution.none)
      expect(subject.reload.pledged).to be_zero
    end
  end

  describe '#total_pledged' do
    subject { create(:match, value_unit: 2) }

    it 'sums matched contributions values and origianl contributions values' do
      create(:contribution, project: subject.project, value: 11)
      expect(subject.reload.total_pledged).to eql(33)
    end

    it 'skips contributions out of available_to_count scope' do
      create(:contribution, project: subject.project, value: 11, state: :canceled)
      Contribution.stub(:available_to_count).and_return(Contribution.none)
      expect(subject.reload.total_pledged).to be_zero
    end
  end

  describe '#complete!' do
    it 'changes its completed value to a truthy value' do
      subject = build(:match)
      subject.complete!
      expect(subject).to be_completed
    end
  end
end
