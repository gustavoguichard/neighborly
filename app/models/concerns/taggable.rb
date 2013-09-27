module Taggable
  extend ActiveSupport::Concern

  class TagList < Array
    cattr_accessor :delimiter
    @@delimiter = ','

    def initialize(list)
      list = list.is_a?(Array) ? list : list.downcase.split(@@delimiter).collect(&:strip).reject(&:blank?)
      super
    end

    def to_s
      join("#{@@delimiter} ")
    end
  end


  included do
    has_many :taggings, dependent: :destroy
    has_many :tags, through: :taggings
    after_save :save_tags

    def tag_list
      TagList.new tags.map(&:name)
    end

    def tag_list=(list)
      @new_tag_list = TagList.new(list)
    end

    protected

    def save_tags
      unassign_tags
      add_new_tags
      taggings.each(&:save)
    end

    def add_new_tags
      return if @new_tag_list.nil?
      @new_tag_list.each do |tag_name|
        tags << Tag.find_or_initialize_by(name: tag_name.downcase) unless tag_list.include?(tag_name.downcase)
      end
    end

    def unassign_tags
      return unless @new_tag_list.present?
      tags.each { |t| taggings.where(tag: t).first.delete unless @new_tag_list.include?(t.name.downcase) }
    end

  end
end
