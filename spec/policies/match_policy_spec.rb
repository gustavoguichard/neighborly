require 'spec_helper'

describe MatchPolicy do
  subject { described_class }
  let(:user)    { User.new }
  let(:project) { Project.new(state: project_state) }
  let(:match)   { Match.new(project: project) }

  permissions :new?, :create? do
    context 'when project is online' do
      let(:project_state) { 'online' }

      it 'should permit access if the project is online' do
        expect(subject).to permit(user, match)
      end
    end

    context 'when project is not online' do
      let(:project_state) { 'draft' }

      it 'should permit access if the project is online' do
        expect(subject).to_not permit(user, match)
      end
    end
  end
end
