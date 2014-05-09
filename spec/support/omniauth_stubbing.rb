OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new(
  YAML.load(
    File.read(Rails.root.join('spec', 'fixtures', 'omniauth_data.yml'))
  )
)

# Stub images

fake_avatar_uri = 'https://graph.facebook.com/fake_avatar.jpg'
FakeWeb.register_uri(:get, %r(https://graph\.facebook\.com/),
  status:   ['301', 'Moved Permanently'],
  location: fake_avatar_uri
)
FakeWeb.register_uri(:get, fake_avatar_uri,
  body:         Rack::Test::UploadedFile.new(
    File.open(Rails.root.join('spec', 'fixtures', 'image.png'))
  ),
  content_type: 'image/jpg'
)
