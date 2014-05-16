require 'spec_helper'

describe MatchFinisher do
  include ActiveSupport::Testing::TimeHelpers

  describe 'matches' do
    context 'with already finished matches' do
      let(:match) do
        travel_to(10.days.ago) do
          create(:match, starts_at: 5.days.from_now, finishes_at: 7.days.from_now)
        end
      end

      context 'with not completed matches' do
        it 'includes matches with contributions on terminated statuses' do
          create(:contribution, project: match.project, state: :confirmed)
          expect(subject.matches).to include(match)
        end

        it 'doesn\'t include matches with contributions waiting confirmation' do
          create(:contribution, project: match.project, state: :waiting_confirmation)
          create(:contribution, project: match.project, state: :confirmed)
          expect(subject.matches).to_not include(match)
        end

        it 'doesn\'t include non confirmed matches' do
          match = travel_to(10.days.ago) do
            create(:match, starts_at: 5.days.from_now, finishes_at: 7.days.from_now, state: :waiting_confirmation)
          end
          create(:contribution, project: match.project, state: :confirmed)
          expect(subject.matches).to_not include(match)
        end
      end

      context 'with completed matches' do
        it 'doesn\'t include any of them' do
          match = create(:match, completed: true)
          create(:contribution, project: match.project)
          expect(subject.matches).to_not include(match)
        end
      end
    end

    context 'with non finished matches' do
      it 'doesn\'t include matches not started' do
        match = travel_to(10.days.from_now) do
          project = create(:project,
            online_days: 10,
            online_date: 2.days.from_now.to_date
          )
          create(:match,
            finishes_at: 4.days.from_now.to_date,
            starts_at:   2.days.from_now.to_date,
            project:     project
          )
        end
        create(:contribution, project: match.project)
        expect(subject.matches).to_not include(match)
      end

      it 'it does not include matches started and not finished yet' do
        match = travel_to(10.days.ago) do
          create(:match, starts_at: 5.days.from_now, finishes_at: 12.days.from_now)
        end
        create(:contribution, project: match.project)
        expect(subject.matches).to_not include(match)
      end
    end
  end

  describe 'remaining amount of matches' do
    let(:match) { create(:match, value: 1_000, value_unit: 1) }
    before do
      create(:contribution, project: match.project, value: 250)
    end

    it 'subtracts amount used in generated contributions from match value' do
      expect(subject.remaining_amount_of(match)).to eql(750)
    end

    Contribution.state_machine.states.map(&:name).delete_if { |name| name.eql? :confirmed }.each do |state|
      it "doesn't take #{state} contributions in count" do
        create(:contribution, project: match.project, value: 250, state: state)
        expect(subject.remaining_amount_of(match)).to eql(750)
      end
    end
  end
end
