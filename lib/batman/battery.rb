require 'batman/errors'

module Batman
  class Battery

    def initialize(battery_index = 0)
      if self.class == Battery
        raise AbstractError.new('cannot instantiate Battery')
      end

      @index = battery_index
    end

    def state
      raise NotImplementedError.new
    end

    def remaining_percent
      raise NotImplementedError.new
    end

    def power
      raise NotImplementedError.new
    end

    def remaining_running_time
      raise NotImplementedError.new
    end

    def remaining_charging_time
      raise NotImplementedError.new
    end

    def remaining_energy
      raise NotImplementedError.new
    end

    def full_energy
      raise NotImplementedError.new
    end

  end
end
