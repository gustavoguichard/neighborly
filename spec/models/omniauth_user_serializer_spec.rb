require 'spec_helper'

describe OmniauthUserSerializer do
  let(:omniauth_fixture) do
    Rails.root.join('spec',
                    'fixtures',
                    'omniauth_data.yml')
  end
  let(:omniauth_data) do
    YAML.load(File.read(omniauth_fixture)).with_indifferent_access
  end
  let!(:oauth_provider) do
    OauthProvider.create(name:   omniauth_data['provider'],
                         key:    '123',
                         secret: '123')
  end
  subject { described_class.new(omniauth_data).to_h }

  it 'defines a name' do
    expect(subject[:name]).to eql('Juquinha da Silva')
  end

  it 'defines an e-mail' do
    expect(subject[:email]).to eql('juquinha@neighbor.ly')
  end

  it 'defines a nickname' do
    expect(subject[:nickname]).to eql('juquinhadasilva')
  end

  describe 'bio' do
    it 'defines one' do
      expect(subject[:bio]).to eql('Lorem ipsum dolor sit amet, consectetur adipisicing elit')
    end

    context 'with big bios received from omniauth' do
      let(:omniauth_data) do
        data = YAML.load(File.read(omniauth_fixture)).with_indifferent_access
        data['info']['description'] = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cill'
        data
      end

      it 'limits it in 140 characters' do
        expect(subject[:bio]).to eql(omniauth_data['info']['description'][0..139])
      end
    end

    context 'with no bio available' do
      let(:omniauth_data) do
        data = YAML.load(File.read(omniauth_fixture)).with_indifferent_access
        data['info'].delete('description')
        data
      end

      it 'skips bio node' do
        expect(subject).to_not have_key(:bio)
      end
    end
  end

  it 'defines a locale' do
    expect(subject[:locale]).to eql(I18n.locale.to_s)
  end

  describe 'authorization' do
    it 'defines an uid' do
      expect(
        subject[:authorizations_attributes][0][:uid]
      ).to eql('1327651586')
    end

    it 'defines an oauth_provider_id' do
      expect(
        subject[:authorizations_attributes][0][:oauth_provider_id]
      ).to eql(oauth_provider.id)
    end

    it 'defines an access_token' do
      expect(
        subject[:authorizations_attributes][0][:access_token]
      ).to eql(omniauth_data['credentials']['token'])
    end
  end
end
