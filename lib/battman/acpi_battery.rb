require 'battman/battery'

module Battman
  class AcpiBattery < Battery

    def initialize(index = 0, **opts)
      super(index)

      @precision = opts[:precision] || 1000
    end

    def path
      @path ||= "/sys/class/power_supply/BAT#{@index}"
    end

    def remaining_percent
      energy_full_file = File.join(path, 'energy_full')
      energy_now_file = File.join(path, 'energy_now')

      energy_full = File.read(energy_full_file)
      energy_now = File.read(energy_now_file)

      (energy_now.to_f / energy_full.to_f) * 100
    end

    def power
      power_now_file = File.join(path, 'power_now')

      power = File.read(power_now_file).to_f / (1000 * @precision)

      state == :discharging ? -1 * power : power
    end

    def state
      state_file = File.join(path, 'status')

      state = File.read(state_file).chomp.downcase.to_sym

      state == :unknown ? :idle : state
    end

    def remaining_energy
      energy_file = File.join(path, 'energy_now')

      File.read(energy_file).to_f / (1000 * @precision)
    end

    def remaining_running_time
      raise WrongStateError if state != :discharging
      (remaining_energy / power) * 60
    end

    def full_energy
      energy_file = File.join(path, 'energy_full')

      File.read(energy_file).to_f / (1000 * @precision)
    end

    def remaining_charging_time
      raise WrongStateError if state != :charging
      ((full_energy - remaining_energy) / power) * 60
    end
  end
end
