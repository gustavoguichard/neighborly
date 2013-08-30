class LegacyPaymentDetail < ActiveRecord::Base
  include LegacyBase
  establish_connection "legacy"

  self.table_name = "payment_details"
  belongs_to :legacy_backer, foreign_key: 'backer_id'

end

