require 'spec_helper'

describe StaticController do

  render_views
  subject{ response }

  describe "GET sitemap" do
    before{ get :sitemap, {locale: :pt} }
    it{ should be_success }
  end
end
