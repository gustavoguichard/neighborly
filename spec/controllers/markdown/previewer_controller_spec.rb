require 'spec_helper'

describe Markdown::PreviewerController do

  describe 'POST \'create\'' do
    it 'renders show view' do
      xhr :post, :create, markdown: "#Hey"
      expect(response).to render_template('markdown/previewer/show')
    end

    it 'assigns html var' do
      xhr :post, :create, markdown: "#Hey"
      expect(assigns(:html)).not_to be_nil
    end

    it 'calls auto_html' do
      expect_any_instance_of(
        Markdown::PreviewerController
      ).to receive(:auto_html).with(anything)

      xhr :post, :create, markdown: "#Hey"
    end
  end

end
