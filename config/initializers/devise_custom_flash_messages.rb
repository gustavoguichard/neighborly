module DeviseCustomFlashMessage
  def self.included klass
    klass.class_eval do
      alias :orifinal_find_message :find_message
      remove_method :find_message
    end
  end

  protected
  def find_message(kind, options = {})
    if kind == :signed_up
      options = { link: edit_user_path(resource) }
    end
    orifinal_find_message kind, options
  end
end

DeviseController.send(:include, DeviseCustomFlashMessage)
