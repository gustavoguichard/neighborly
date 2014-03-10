module DeviseCustomFlashMessage
  def self.included klass
    klass.class_eval do
      alias :original_find_message :find_message
      remove_method :find_message
    end
  end

  protected
  def find_message(kind, options = {})
    if kind == :signed_up || (kind == :signed_in && resource.completeness_progress < 100)
      options = { link: edit_user_path(resource) }
    end
    kind = :signed_in_custom if kind == :signed_in && resource.completeness_progress < 100

    original_find_message kind, options
  end
end

DeviseController.send(:include, DeviseCustomFlashMessage)
