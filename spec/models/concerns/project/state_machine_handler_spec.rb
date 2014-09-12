require 'spec_helper'

describe Project::StateMachineHandler do
  let(:user){ create(:user) }

  describe "state machine" do
    let(:project) { create(:project, state: 'draft', online_date: nil) }

    describe '#draft?' do
      subject { project.draft? }
      context "when project is new" do
        it { should be_true }
      end
    end

    describe '#approve' do
      before { project.push_to_draft }

      subject do
        expect(project).to receive(:notify_observers).with(:from_draft_to_soon)
        project.approve!
        project
      end

      it 'changes the state to soon' do
        expect(subject.soon?).to be_true
      end

      it('should call after transition method to notify the project owner'){ subject }
    end

    describe '.push_to_draft' do
      subject do
        project.reject
        project.push_to_draft
        project
      end
      its(:draft?){ should be_true }
    end

    describe '#rejected?' do
      subject { project.rejected? }
      before do
        project.push_to_draft
        project.reject
      end
      context 'when project is not accepted' do
        it { should be_true }
      end
    end

    describe '#reject' do
      before { project.update_attributes state: 'draft' }
      subject do
        project.should_receive(:notify_observers).with(:from_draft_to_rejected)
        project.reject
        project
      end
      its(:rejected?){ should be_true }
    end

    describe '#push_to_trash' do
      let(:project) { create(:project, permalink: 'my_project', state: 'draft') }

      subject do
        project.push_to_trash
        project
      end

      its(:deleted?) { should be_true }
      its(:permalink) { should == "deleted_project_#{project.id}" }
    end

    describe '#launch' do
      before { project.push_to_draft }

      subject do
        project.should_receive(:notify_observers).with(:from_draft_to_online)
        project.launch
        project
      end

      its(:online?){ should be_true }
      it('should call after transition method to notify the project owner'){ subject }
      it 'should persist the online_date' do
        project.launch
        expect(project.online_date).to_not be_nil
      end
    end

    describe '#online?' do
      before do
        project.push_to_draft
        project.launch
      end
      subject { project.online? }
      it { should be_true }
    end

    describe '#finish' do
      let(:main_project) { create(:project, goal: 30_000, online_days: -1) }
      subject { main_project }

      context 'when project is not online' do
        before do
          main_project.update_attributes state: 'draft'
        end
        its(:finish) { should be_false }
      end

      context 'when project is expired and have recent contributions without confirmation' do
        before do
          create(:contribution, value: 30_000, project: subject, state: 'waiting_confirmation')
          subject.finish
        end

        its(:waiting_funds?) { should be_true }
      end

      context 'when project already hit the goal and passed the waiting_funds time' do
        before do
          main_project.update_attributes state: 'waiting_funds'
          subject.stub(:pending_contributions_reached_the_goal?).and_return(true)
          subject.stub(:reached_goal?).and_return(true)
          subject.online_date = 2.weeks.ago
          subject.online_days = 0
        end

        context "when campaign type is flexible" do
          before do
            main_project.update_attributes campaign_type: 'flexible'
            subject.finish
          end

          its(:successful?) { should be_true }
        end
      end

      context 'when project already hit the goal and still is in the waiting_funds time' do
        before do
          subject.stub(:pending_contributions_reached_the_goal?).and_return(true)
          subject.stub(:reached_goal?).and_return(true)
          create(:contribution, project: main_project, user: user, value: 20, state: 'waiting_confirmation')
          main_project.update_attributes state: 'waiting_funds'
        end

        context "when project is flexible" do
          before do
            main_project.update_attributes campaign_type: 'flexible'
            subject.finish
          end

          its(:successful?) { should be_false }
        end
      end
    end
  end
end
