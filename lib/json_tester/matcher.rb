module JsonTester
  class Matcher
    def initialize(hash, options = {})
      defaults = {}
      @hash = hash
      @options = defaults.merge(options)
      reset!
    end
  end
end