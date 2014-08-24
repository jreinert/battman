require 'battman/errors'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/numeric/time'

module Battman
  class Battery

    CONVERSIONS = {
      power: {
        watts: lambda {|value| value},
        milliwatts: lambda {|value| value * 1000}
      },
      time: {
        seconds: lambda {|value| value},
        minutes: lambda {|value| value.to_f / 1.minute},
        hours: lambda {|value| value.to_f / 1.hour}
      },
      energy: {
        watt_hours: lambda {|value| value},
        milliwatt_hours: lambda {|value| value * 1000}
      }
    }

    def initialize(battery_index = 0, **opts)
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

    def power_in(unit)
      unless unit.in?(CONVERSIONS[:power].keys)
        raise UnsupportedUnitError.new(unit)
      end

      CONVERSIONS[:power][unit].call(power)
    end

    def remaining_running_time
      raise NotImplementedError.new
    end

    def remaining_running_time_in(unit)
      unless unit.in?(CONVERSIONS[:time].keys)
        raise UnsupportedUnitError.new(unit)
      end

      CONVERSIONS[:time][unit].call(remaining_running_time)
    end

    def remaining_charging_time
      raise NotImplementedError.new
    end

    def remaining_charging_time_in(unit)
      unless unit.in?(CONVERSIONS[:time].keys)
        raise UnsupportedUnitError.new(unit)
      end

      CONVERSIONS[:time][unit].call(remaining_charging_time)
    end

    def remaining_energy
      raise NotImplementedError.new
    end

    def remaining_energy_in(unit)
      unless unit.in?(CONVERSIONS[:energy].keys)
        raise UnsupportedUnitError.new(unit)
      end

      CONVERSIONS[:energy][unit].call(remaining_energy)
    end

    def full_energy
      raise NotImplementedError.new
    end

    def full_energy_in(unit)
      unless unit.in?(CONVERSIONS[:energy].keys)
        raise UnsupportedUnitError.new(unit)
      end

      CONVERSIONS[:energy][unit].call(full_energy)
    end

  end
end
