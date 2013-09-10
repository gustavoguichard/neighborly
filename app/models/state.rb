class State < ActiveRecord::Base
  validates_presence_of :name, :acronym
  validates_uniqueness_of :name, scope: :acronym
  validates_uniqueness_of :acronym, scope: :name

  def self.array
    return @array if @array
    @array = [['Select an option', '']]
    self.order(:name).each do |state|
      @array << ["#{state.name} - #{state.acronym}", state.acronym]
    end
    @array
  end
end
