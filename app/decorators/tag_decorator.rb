class TagDecorator < Draper::Decorator
  decorates :tag
  include Draper::LazyHelpers

  def display_name
    source.name.titleize
  end
end
