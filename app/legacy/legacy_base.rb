module LegacyBase
  def migrate(other_map={})
    new_map = map.merge(other_map)

    if @record = self.class.to_s.gsub(/Legacy/,'::').constantize.where(migrate_where).first
      # Update record at id
      @record.update_attributes(new_map)
    else
      # New record
      @record = self.class.to_s.gsub(/Legacy/,'::').constantize.new(new_map)
      @record[:id] = self.id unless dont_migrate_ids

      associate.each do |association, value|
        @record.send("#{association.to_s}=", value)
      end

      begin
        @record.save!
      rescue Exception => e
        # this is mostly for ActiveRecord Validation errors - if the validation fails, it
        # typically means you need to adjust the validations or the model you're migrating
        # your legacy data into. this is especially useful information when you're migrating
        # user data established with one auth library to a code base which uses another.
        puts "error saving #{@record.class} #{@record.id}!"
        puts e.inspect
      end
    end
  end
end
