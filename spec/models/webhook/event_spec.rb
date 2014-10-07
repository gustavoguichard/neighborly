require 'spec_helper'

describe Webhook::Event do
  it { validate_presence_of :record }
  it { validate_presence_of :kind }
end
