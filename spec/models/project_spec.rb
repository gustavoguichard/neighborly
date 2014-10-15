# coding: utf-8
require 'spec_helper'

describe Project do
  include ActiveSupport::Testing::TimeHelpers

  let(:project){ build(:project, goal: 3000) }
  let(:user){ create(:user) }

  describe "associations" do
    it{ should belong_to :user }
    it{ should belong_to :category }
    it{ should have_one :project_total }
    it{ should have_many :contributions }
    it{ should have_many :rewards }
    it{ should have_many :notifications }
    it{ should have_many :project_faqs }
    it{ should have_many :project_documents }
    it{ should have_many :activities }
  end

  describe "validations" do
    %w[name user category summary headline goal permalink statement_file_url minimum_investment].each do |field|
      it{ should validate_presence_of field }
    end
    it{ should ensure_length_of(:headline).is_at_most(140) }
    it{ should allow_value('http://vimeo.com/12111').for(:video_url) }
    it{ should allow_value('vimeo.com/12111').for(:video_url) }
    it{ should allow_value('https://vimeo.com/12111').for(:video_url) }
    it{ should allow_value('http://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should allow_value('youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should allow_value('https://youtube.com/watch?v=UyU-xI').for(:video_url) }
    it{ should_not allow_value('http://www.foo.bar').for(:video_url) }
    it{ should allow_value('testproject').for(:permalink) }
    it{ should_not allow_value('users').for(:permalink) }
  end

  describe 'scopes' do
    describe ".visible" do
      before do
        [:draft, :rejected, :deleted].each do |state|
          create(:project, state: state)
        end
        @project = create(:project, state: :online)
      end
      subject{ Project.visible }
      it{ should == [@project] }
    end

    describe '.active' do
      before do
        create(:project, state: :successful)
        @project = create(:project, state: :online)
      end

      it 'returns only the online project' do
        expect(described_class.active).to eq [@project]
      end
    end

    describe '.to_finish' do
      before do
        Project.should_receive(:expired).and_call_original
        Project.should_receive(:with_states).with(['online', 'waiting_funds']).and_call_original
      end
      it "should call scope expired and filter states that can be finished" do
        Project.to_finish
      end
    end

    describe ".contributed_by" do
      before do
        contribution = create(:contribution, state: 'confirmed')
        @user = contribution.user
        @project = contribution.project
        # Another contribution with same project and user should not create duplicate results
        create(:contribution, user: @user, project: @project, state: 'confirmed')
        # Another contribution with other project and user should not be in result
        create(:contribution, state: 'confirmed')
        # Another contribution with different project and same user but not confirmed should not be in result
        create(:contribution, user: @user, state: 'pending')
      end
      subject{ Project.contributed_by(@user.id) }
      it{ should == [@project] }
    end

    describe ".expired" do
      before do
        @p = create(:project, online_days: -1)
        create(:project, online_days: 1)
      end
      subject{ Project.expired}
      it{ should == [@p] }
    end

    describe ".not_expired" do
      before do
        @p = create(:project, online_days: 1)
        create(:project, online_days: -1)
      end
      subject{ Project.not_expired }
      it{ should == [@p] }
    end

    describe ".expiring" do
      before do
        @p = create(:project, online_date: Time.now, online_days: 13)
        create(:project, online_date: Time.now, online_days: -1)
      end
      subject{ Project.expiring }
      it{ should == [@p] }
    end

    describe ".not_expiring" do
      before do
        @p = create(:project, online_days: 15)
        create(:project, online_days: -1)
      end
      subject{ Project.not_expiring }
      it{ should == [@p] }
    end

    describe ".recent" do
      before do
        @p = create(:project, online_date: (Time.now - 4.days))
        create(:project, online_date: (Time.now - 15.days))
      end
      subject{ Project.recent }
      it{ should == [@p] }
    end
  end

  describe '.state_names' do
    let(:states) { [:draft, :soon, :rejected, :online, :successful, :waiting_funds] }

    subject { Project.state_names }

    it { should == states }
  end

  describe '.locations' do
    before do
      create(:project, location: 'San Francisco, CA')
      create(:project, location: 'Kansas City, MO')
      create(:project, location: 'Kansas City, MO')
      create(:project, location: 'Kansas City, KS', state: 'draft')
    end
    subject { Project.locations }
    it { should have(2).items }
  end

  describe ".find_by_permalink!" do
    context "when project is deleted" do
      before do
        @p = create(:project, permalink: 'foo', state: 'deleted')
        create(:project, permalink: 'bar')
      end
      it{ expect {Project.find_by_permalink!('foo')}.to raise_error(ActiveRecord::RecordNotFound) }
    end
    context "when project is not deleted" do
      before do
        @p = create(:project, permalink: 'foo')
        create(:project, permalink: 'bar')
      end
      subject{ Project.find_by_permalink!('foo') }
      it{ should == @p }
    end
  end

  describe '.order_by' do
    subject { Project.last.name }

    before do
      create(:project, name: 'lorem')
      #testing for sql injection
      Project.order_by("goal asc;update projects set name ='test';select * from projects ").first #use first so the sql is actually executed
    end

    it { should == 'lorem' }
  end

  describe '#reached_goal?' do
    subject { create(:project, goal: 3000) }

    context 'when sum of all contributions hit the goal' do
      before do
        create(:contribution, value: 4000, project: subject)
      end

      it { expect(subject).to be_reached_goal }
    end

    context "when sum of all contributions don't hit the goal" do
      it { expect(subject).to_not be_reached_goal }
    end
  end

  describe '#in_time_to_wait?' do
    let(:contribution) { create(:contribution, state: 'waiting_confirmation') }
    subject { contribution.project.in_time_to_wait? }

    context 'when project expiration is in time to wait' do
      it { should be_true }
    end

    context 'when project expiration time is not more on time to wait' do
      let(:contribution) { create(:contribution, created_at: 1.week.ago) }
      it {should be_false}
    end
  end


  describe "#pg_search" do
    before { @p = create(:project, name: 'foo') }
    context "when project exists" do
      subject{ [Project.pg_search('foo'), Project.pg_search('fóõ')] }
      it{ should == [[@p],[@p]] }
    end
    context "when project is not found" do
      subject{ Project.pg_search('lorem') }
      it{ should == [] }
    end
  end

  describe "#pledged_and_waiting" do
    subject{ project.pledged_and_waiting }
    before do
      @confirmed = create(:contribution, value: 10, state: 'confirmed', project: project)
      @waiting = create(:contribution, value: 10, state: 'waiting_confirmation', project: project)
      create(:contribution, value: 100, state: 'refunded', project: project)
      create(:contribution, value: 1000, state: 'pending', project: project)
    end
    it{ should == @confirmed.value + @waiting.value }
  end

  describe "#expired?" do
    subject{ project.expired? }

    context "when online_date is nil" do
      let(:project){ Project.new online_date: nil, online_days: 0 }
      it{ should be_false }
    end

    context "when expires_at is in the future" do
      let(:project){ Project.new online_date: 2.days.from_now, online_days: 0 }
      it{ should be_false }
    end

    context "when expires_at is in the past" do
      let(:project){ Project.new online_date: 2.days.ago, online_days: 0 }
      it{ should be_true }
    end
  end

  describe "#expires_at" do
    subject{ project.expires_at }
    context "when we do not have an online_date" do
      let(:project){ build(:project, online_date: nil, online_days: 0) }
      it{ should be_nil }
    end
    context "when we have an online_date" do
      let(:project){ build(:project, online_date: Time.now, online_days: 0) }
      it{ should == Time.zone.now.end_of_day }
    end
  end

  describe '#selected_rewards' do
    let(:project){ create(:project) }
    let(:reward_01) { create(:reward, project: project) }
    let(:reward_02) { create(:reward, project: project) }
    let(:reward_03) { create(:reward, project: project) }

    before do
      create(:contribution, state: 'confirmed', project: project, reward: reward_01)
      create(:contribution, state: 'confirmed', project: project, reward: reward_03)
    end

    subject { project.selected_rewards }
    it { should == [reward_01, reward_03] }
  end

  describe '#pending_contributions_reached_the_goal?' do
    let(:project) { create(:project, goal: 200) }

    before { project.stub(:pleged) { 100 } }

    subject { project.pending_contributions_reached_the_goal? }

    context 'when reached the goal with pending contributions' do
      before { 2.times { create(:contribution, project: project, value: 120, state: 'waiting_confirmation') } }

      it { should be_true }
    end

    context 'when dont reached the goal with pending contributions' do
      before { 2.times { create(:contribution, project: project, value: 30, state: 'waiting_confirmation') } }

      it { should be_false }
    end
  end

  describe "#new_draft_recipient" do
    subject { project.new_draft_recipient }
    before do
      @user = create(:user, email: Configuration[:email_projects].dup)
    end
    it{ should == @user }
  end

  describe 'Taggable' do
    describe 'associations' do
      it{ should have_many(:tags).through(:taggings) }
      it{ should have_many :taggings }
    end

    describe 'TagList' do
      context 'should split the list' do
        subject { Taggable::TagList.new 'Tag 1, Tag 2, Tag 3' }

        context '#initializer' do
          it { should == ['tag 1', 'tag 2', 'tag 3'] }
        end

        context '#to_s' do
          it { expect(subject.to_s).to eq 'tag 1, tag 2, tag 3' }
        end
      end
    end

    describe '#tag_list' do
      before do
        project.tags = ['Tag 1', 'Tag 2', 'Tag 3'].map {|tag_name| Tag.find_or_create_by(name: tag_name.downcase) }
      end

      it { expect(project.tag_list).to have(3).tags }
    end

    describe '#tag_list=' do
      context 'as method' do
        before do
          project.tag_list = 'Tag 1, Tag 2, Tag 3, Tag 4'
          project.save
        end

        it { expect(project.tags).to have(4).tags }
      end

      context 'as attribute' do
        let(:project_with_tags) { create(:project, tag_list: 'Tag 1, Tag 2') }

        it { expect(project_with_tags.tags).to have(2).tags }
      end

      context 'unassign tags' do
        before do
          project.tag_list = 'Tag 1, Tag 2, Tag 3, Tag 4'
          project.save

          project.tag_list = 'Tag 1, Tag 2, Tag 3'
          project.save
          project.reload
        end

        it { expect(project.tags).to have(3).tags }
      end
    end
  end
end
