class Matching < ActiveRecord::Base
  belongs_to :contribution
  belongs_to :match
end
