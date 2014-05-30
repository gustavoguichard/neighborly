class Configuration
  class << self
    def [](key)
      get(key)
    end

    def fetch(key)
      get(key) or raise "No \"#{key}\" configuration defined."
    end

    def []=(key, value)
      set(key, value)
    end

    private

    def get(key)
      ENV[key.to_s.upcase]
    end

    def set(key, value)
      ENV[key.to_s.upcase] = value.to_s
    end
  end
end
