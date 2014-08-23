require 'batman/errors'

module Batman
  class Battery

    def initialize
      if self.class == Battery
        raise AbstractError.new('cannot instantiate Battery')
      end
    end

    def remaining_percent
      raise NotImplementedError.new
    end

    def power
      raise NotImplementedError.new
    end

    def remaining_time
      raise NotImplementedError.new
    end
  end
end
